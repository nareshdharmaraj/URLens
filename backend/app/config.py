"""Configuration management for URLens API"""
from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    """Application settings"""
    
    # Server Configuration
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    ENVIRONMENT: str = "development"
    
    # CORS Settings
    ALLOWED_ORIGINS: str = "*"
    
    # Application Settings
    APP_NAME: str = "URLens API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True
    
    # yt-dlp Settings
    MAX_DOWNLOAD_SIZE: int = 500000000  # 500MB
    TIMEOUT: int = 30
    
    @property
    def cors_origins(self) -> List[str]:
        """Parse ALLOWED_ORIGINS into a list"""
        if self.ALLOWED_ORIGINS == "*":
            return ["*"]
        return [origin.strip() for origin in self.ALLOWED_ORIGINS.split(",")]
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
