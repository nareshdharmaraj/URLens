"""Proxy download endpoint"""

from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import StreamingResponse
import httpx
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
    url: str = Query(..., description="The URL to download from"),
    filename: str = Query(..., description="The filename for the download"),
):
    """
    Proxy endpoint to stream downloads from external sources

    This endpoint acts as a proxy to bypass CORS restrictions when downloading
    media files from external sources (YouTube, etc.) in web browsers.

    - **url**: The direct download URL from yt-dlp
    - **filename**: The desired filename for the download

    Returns: Streaming file response
    """
    logger.info(f"Proxying download for: {filename}")

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
        # Only raise 500 if we haven't started streaming yet (which is true here)
        raise HTTPException(status_code=500, detail=f"Download failed: {str(e)}")
