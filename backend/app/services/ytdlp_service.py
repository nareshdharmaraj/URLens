"""yt-dlp service wrapper"""
import yt_dlp
from typing import Dict, List, Any
from app.core.logger import logger
from app.core.exceptions import (
    UnsupportedURLException,
    PrivateContentException,
    ExtractionException,
    NetworkException
)
from app.config import settings


class YTDLPService:
    """Service for interacting with yt-dlp"""
    
    def __init__(self):
        """Initialize yt-dlp options"""
        self.base_options = {
            'quiet': not settings.DEBUG,
            'no_warnings': not settings.DEBUG,
            'socket_timeout': settings.TIMEOUT,
            'no_check_certificate': False,
            'prefer_insecure': False,
        }
    
    def extract_info(self, url: str, download: bool = False) -> Dict[str, Any]:
        """
        Extract information from URL using yt-dlp
        
        Args:
            url: The URL to extract information from
            download: Whether to download the file
            
        Returns:
            Dictionary containing extracted information
            
        Raises:
            UnsupportedURLException: If URL is not supported
            PrivateContentException: If content is private/restricted
            ExtractionException: If extraction fails
            NetworkException: If network error occurs
        """
        options = {
            **self.base_options,
            'skip_download': not download,
        }
        
        try:
            with yt_dlp.YoutubeDL(options) as ydl:  # type: ignore
                logger.info(f"Extracting info from: {url}")
                info = ydl.extract_info(url, download=download)
                return info  # type: ignore
                
        except yt_dlp.utils.UnsupportedError as e:  # type: ignore
            logger.error(f"Unsupported URL: {url}")
            raise UnsupportedURLException(str(e))
            
        except yt_dlp.utils.DownloadError as e:  # type: ignore
            error_msg = str(e).lower()
            
            if 'private' in error_msg or 'not available' in error_msg:
                logger.error(f"Private/unavailable content: {url}")
                raise PrivateContentException("Content is private or not available")
            elif 'geo' in error_msg or 'restricted' in error_msg:
                logger.error(f"Geo-restricted content: {url}")
                raise PrivateContentException("Content is geographically restricted")
            else:
                logger.error(f"Download error: {e}")
                raise ExtractionException(str(e))
                
        except Exception as e:
            error_msg = str(e).lower()
            
            if 'network' in error_msg or 'connection' in error_msg or 'timeout' in error_msg:
                logger.error(f"Network error: {e}")
                raise NetworkException(str(e))
            else:
                logger.error(f"Unexpected error: {e}")
                raise ExtractionException(f"Failed to extract information: {str(e)}")
    
    def get_metadata(self, url: str) -> Dict[str, Any]:
        """
        Get basic metadata from URL without downloading
        
        Args:
            url: The URL to get metadata from
            
        Returns:
            Dictionary with platform, title, and thumbnail_url
        """
        info = self.extract_info(url, download=False)
        
        # Extract platform name
        platform = info.get('extractor_key', 'unknown').lower()
        if 'youtube' in platform:
            platform = 'youtube'
        elif 'instagram' in platform:
            platform = 'instagram'
        elif 'twitter' in platform or 'x.com' in platform:
            platform = 'twitter'
        elif 'facebook' in platform:
            platform = 'facebook'
        elif 'tiktok' in platform:
            platform = 'tiktok'
        
        return {
            'platform': platform,
            'title': info.get('title', 'Unknown Title'),
            'thumbnail_url': info.get('thumbnail', None)
        }
    
    def get_download_options(self, url: str) -> List[Dict[str, Any]]:
        """
        Get available download options for URL
        
        Args:
            url: The URL to get download options for
            
        Returns:
            List of download options with quality, extension, size, and URL
        """
        info = self.extract_info(url, download=False)
        formats = info.get('formats', [])
        
        if not formats:
            raise ExtractionException("No formats available for this URL")
        
        options = []
        seen_combinations = set()
        
        # Process video formats
        for fmt in formats:
            # Skip formats without URL
            if not fmt.get('url'):
                continue
            
            ext = fmt.get('ext', 'mp4')
            height = fmt.get('height')
            vcodec = fmt.get('vcodec', 'none')
            acodec = fmt.get('acodec', 'none')
            filesize = fmt.get('filesize') or fmt.get('filesize_approx')
            
            if height and vcodec != 'none':
                quality_label = f"{height}p"
                
                # Check if it's video-only (common with high quality YouTube streams)
                if acodec == 'none':
                    quality_label += " (Video Only)"
                
                combination = (quality_label, ext, 'video')
                
                if combination not in seen_combinations:
                    seen_combinations.add(combination)
                    options.append({
                        'quality_label': quality_label,
                        'extension': ext,
                        'file_size_approx': filesize,
                        'download_url': fmt['url']
                    })
            
            # Audio-only formats
            elif acodec != 'none' and vcodec == 'none':
                quality_label = "Audio Only"
                combination = (quality_label, ext, 'audio')
                
                if combination not in seen_combinations:
                    seen_combinations.add(combination)
                    options.append({
                        'quality_label': quality_label,
                        'extension': ext,
                        'file_size_approx': filesize,
                        'download_url': fmt['url']
                    })
        
        # If no suitable formats found, add the best format
        if not options and formats:
            best_format = formats[-1]
            options.append({
                'quality_label': 'Best Available',
                'extension': best_format.get('ext', 'mp4'),
                'file_size_approx': best_format.get('filesize') or best_format.get('filesize_approx'),
                'download_url': best_format['url']
            })
        
        # Sort by quality (descending)
        def sort_key(opt):
            label = opt['quality_label']
            if label == 'Audio Only':
                return 0
            elif label == 'Best Available':
                return 9999
            else:
                try:
                    return int(label.replace('p', ''))
                except:
                    return 500
        
        options.sort(key=sort_key, reverse=True)
        
        return options


# Global instance
ytdlp_service = YTDLPService()
