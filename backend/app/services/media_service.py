"""Media service for business logic"""
from typing import Dict, List, Any
from app.services.ytdlp_service import ytdlp_service
from app.models.responses import AnalyzeResponse, DownloadOption, DownloadInfoResponse
from app.core.logger import logger


class MediaService:
    """Service for media-related operations"""
    
    def __init__(self):
        """Initialize media service"""
        self.ytdlp = ytdlp_service
    
    async def analyze_url(self, url: str) -> AnalyzeResponse:
        """
        Analyze URL and return metadata
        
        Args:
            url: The URL to analyze
            
        Returns:
            AnalyzeResponse with platform, title, and thumbnail
        """
        logger.info(f"Analyzing URL: {url}")
        metadata = self.ytdlp.get_metadata(url)
        
        return AnalyzeResponse(
            platform=metadata['platform'],
            title=metadata['title'],
            thumbnail_url=metadata.get('thumbnail_url')
        )
    
    async def get_download_info(self, url: str) -> DownloadInfoResponse:
        """
        Get download options for URL
        
        Args:
            url: The URL to get download info for
            
        Returns:
            DownloadInfoResponse with list of download options
        """
        logger.info(f"Getting download info for: {url}")
        options = self.ytdlp.get_download_options(url)
        
        download_options = [
            DownloadOption(
                quality_label=opt['quality_label'],
                extension=opt['extension'],
                file_size_approx=opt.get('file_size_approx'),
                download_url=opt['download_url']
            )
            for opt in options
        ]
        
        return DownloadInfoResponse(download_options=download_options)


# Global instance
media_service = MediaService()
