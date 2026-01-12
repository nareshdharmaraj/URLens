"""Response models"""
from pydantic import BaseModel
from typing import List, Optional


class AnalyzeResponse(BaseModel):
    """Response model for URL analysis"""
    platform: str
    title: str
    thumbnail_url: Optional[str] = None
    
    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "platform": "youtube",
                    "title": "Rick Astley - Never Gonna Give You Up (Official Music Video)",
                    "thumbnail_url": "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg"
                }
            ]
        }
    }


class DownloadOption(BaseModel):
    """Single download option"""
    quality_label: str
    extension: str
    file_size_approx: Optional[int] = None
    download_url: str
    
    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "quality_label": "1080p",
                    "extension": "mp4",
                    "file_size_approx": 45582999,
                    "download_url": "https://direct-expiring-link..."
                }
            ]
        }
    }


class DownloadInfoResponse(BaseModel):
    """Response model for download information"""
    download_options: List[DownloadOption]
    
    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "download_options": [
                        {
                            "quality_label": "1080p",
                            "extension": "mp4",
                            "file_size_approx": 45582999,
                            "download_url": "https://direct-expiring-link-to-1080p-video..."
                        },
                        {
                            "quality_label": "720p",
                            "extension": "mp4",
                            "file_size_approx": 25165824,
                            "download_url": "https://direct-expiring-link-to-720p-video..."
                        }
                    ]
                }
            ]
        }
    }
