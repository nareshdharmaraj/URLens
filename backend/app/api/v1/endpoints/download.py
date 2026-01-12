"""Download endpoint"""
from fastapi import APIRouter
from app.models.requests import URLRequest
from app.models.responses import DownloadInfoResponse
from app.services.media_service import media_service
from app.core.logger import logger

router = APIRouter()


@router.post("/download-info", response_model=DownloadInfoResponse, tags=["media"])
async def get_download_info(request: URLRequest):
    """
    Get download options for a URL
    
    This endpoint returns a list of available download formats and qualities
    with direct download URLs for each option.
    
    - **url**: The URL to get download options for (required)
    
    Returns:
    - download_options: List of available formats with:
        - quality_label: Quality description (e.g., "1080p", "Audio Only")
        - extension: File extension (e.g., "mp4", "m4a")
        - file_size_approx: Approximate file size in bytes
        - download_url: Direct download URL
    """
    logger.info(f"Received download-info request for: {request.url}")
    
    try:
        result = await media_service.get_download_info(request.url)
        logger.info(f"Successfully retrieved download info for: {request.url}")
        return result
        
    except Exception as e:
        logger.error(f"Failed to get download info: {str(e)}")
        raise
