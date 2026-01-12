"""Analyze endpoint"""
from fastapi import APIRouter, HTTPException
from app.models.requests import URLRequest
from app.models.responses import AnalyzeResponse
from app.services.media_service import media_service
from app.core.logger import logger

router = APIRouter()


@router.post("/analyze", response_model=AnalyzeResponse, tags=["media"])
async def analyze_url(request: URLRequest):
    """
    Analyze a URL and return basic metadata
    
    This endpoint takes a URL and returns platform information,
    title, and thumbnail without downloading the actual media.
    
    - **url**: The URL to analyze (required)
    
    Returns metadata including:
    - platform: Source platform (e.g., youtube, instagram)
    - title: Media title
    - thumbnail_url: URL to thumbnail image
    """
    logger.info(f"Received analyze request for: {request.url}")
    
    try:
        result = await media_service.analyze_url(request.url)
        logger.info(f"Successfully analyzed: {request.url}")
        return result
        
    except Exception as e:
        logger.error(f"Failed to analyze URL: {str(e)}")
        raise
