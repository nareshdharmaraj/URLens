"""Request models"""
from pydantic import BaseModel, HttpUrl, field_validator


class URLRequest(BaseModel):
    """Request model for URL-based endpoints"""
    url: str
    
    @field_validator('url')
    @classmethod
    def validate_url(cls, v: str) -> str:
        """Validate URL format"""
        if not v or not v.strip():
            raise ValueError('URL cannot be empty')
        
        # Basic URL validation
        v = v.strip()
        if not (v.startswith('http://') or v.startswith('https://')):
            raise ValueError('URL must start with http:// or https://')
        
        return v
    
    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
                }
            ]
        }
    }
