"""Proxy download endpoint"""

from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import StreamingResponse
import httpx
import yt_dlp
import tempfile
import os
from app.core.logger import logger

router = APIRouter()


@router.get("/proxy", tags=["media"])
async def proxy_content(
    url: str = Query(..., description="The URL to proxy"),
):
    """
    Generic proxy endpoint for images/content
    """
    # Use distinct client for this simple proxy
    client = httpx.AsyncClient(timeout=30.0, follow_redirects=True)
    try:
        req = client.build_request("GET", url)
        response = await client.send(req, stream=True)

        if response.status_code != 200:
            await response.aclose()
            await client.aclose()
            raise HTTPException(status_code=response.status_code)

        content_type = response.headers.get("content-type", "application/octet-stream")

        async def cleanup():
            await response.aclose()
            await client.aclose()

        return StreamingResponse(
            response.aiter_bytes(chunk_size=8192),
            media_type=content_type,
            background=cleanup,
        )
    except Exception as e:
        await client.aclose()
        logger.error(f"Proxy failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/proxy-download", tags=["media"])
async def proxy_download(
    url: str = Query(..., description="The URL to download from or format selector"),
    filename: str = Query(..., description="The filename for the download"),
):
    """
    Proxy endpoint to stream downloads from external sources

    This endpoint acts as a proxy to bypass CORS restrictions when downloading
    media files from external sources. Supports both direct URLs and merged formats.

    - **url**: The direct download URL or MERGE:format_id+format_id for merged streams
    - **filename**: The desired filename for the download

    Returns: Streaming file response
    """
    logger.info(f"Proxying download for: {filename}")

    # Check if this is a merged format request
    if url.startswith("MERGE:"):
        # Extract format IDs
        format_selector = url.replace("MERGE:", "")
        logger.info(f"Merging formats: {format_selector}")

        # We need the original URL to download with yt-dlp
        # For now, return an error asking for the original URL
        # The frontend should send the original URL in this case
        raise HTTPException(
            status_code=400,
            detail="Merged format downloads require using yt-dlp directly. Please use the original video URL.",
        )

    # Regular direct URL download
    client = httpx.AsyncClient(timeout=300.0, follow_redirects=True)
    try:
        req = client.build_request("GET", url)
        response = await client.send(req, stream=True)

        if response.status_code != 200:
            await response.aclose()
            await client.aclose()
            raise HTTPException(
                status_code=response.status_code,
                detail=f"Failed to download from source: {response.status_code}",
            )

        # Get content type and length
        content_type = response.headers.get("content-type", "application/octet-stream")
        content_length = response.headers.get("content-length")

        # Create headers
        headers = {
            "Content-Disposition": f'attachment; filename="{filename}"',
        }

        if content_length:
            headers["Content-Length"] = content_length

        async def cleanup():
            await response.aclose()
            await client.aclose()
            logger.info(f"Finished proxy download for: {filename}")

        return StreamingResponse(
            response.aiter_bytes(chunk_size=8192),
            media_type=content_type,
            headers=headers,
            background=cleanup,
        )

    except httpx.TimeoutException:
        await client.aclose()
        logger.error(f"Timeout while downloading: {filename}")
        raise HTTPException(status_code=504, detail="Download timeout")

    except Exception as e:
        await client.aclose()
        logger.error(f"Failed to proxy download: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Download failed: {str(e)}")


@router.get("/download-merged", tags=["media"])
async def download_merged(
    original_url: str = Query(..., description="The original video URL"),
    format_id: str = Query(..., description="Format selector (e.g., '123+456')"),
    filename: str = Query(..., description="The filename for the download"),
):
    """
    Download and merge video+audio streams using yt-dlp

    This endpoint uses yt-dlp to download and merge separate video and audio streams
    into a single file, which is common for Instagram, Twitter, etc.

    - **original_url**: The original video URL (not the stream URL)
    - **format_id**: The format selector (e.g., "123+456" for video+audio merge)
    - **filename**: The desired filename

    Returns: Streaming merged file
    """
    logger.info(f"Downloading merged format {format_id} from: {original_url}")

    # Create temporary directory for download
    temp_dir = tempfile.mkdtemp()
    temp_output = os.path.join(temp_dir, "download")

    try:
        # Configure yt-dlp to download and merge
        ydl_opts = {
            "format": format_id,
            "outtmpl": temp_output,
            "merge_output_format": "mp4",
            "quiet": True,
            "no_warnings": True,
        }

        # Download and merge using yt-dlp
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            ydl.download([original_url])

        # Find the output file (it might have extension added)
        output_file = None
        for file in os.listdir(temp_dir):
            if file.startswith("download"):
                output_file = os.path.join(temp_dir, file)
                break

        if not output_file or not os.path.exists(output_file):
            raise HTTPException(status_code=500, detail="Failed to create merged file")

        # Stream the file
        def iterfile():
            with open(output_file, "rb") as f:
                while chunk := f.read(8192):
                    yield chunk
            # Cleanup after streaming
            try:
                os.remove(output_file)
                os.rmdir(temp_dir)
            except:
                pass

        file_size = os.path.getsize(output_file)

        return StreamingResponse(
            iterfile(),
            media_type="video/mp4",
            headers={
                "Content-Disposition": f'attachment; filename="{filename}"',
                "Content-Length": str(file_size),
            },
        )

    except Exception as e:
        # Cleanup on error
        try:
            if os.path.exists(temp_dir):
                import shutil

                shutil.rmtree(temp_dir)
        except:
            pass
        logger.error(f"Failed to download merged format: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Merge download failed: {str(e)}")
