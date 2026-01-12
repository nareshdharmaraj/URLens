"""Logging configuration"""
import logging
import sys
from app.config import settings


def setup_logger() -> logging.Logger:
    """Configure and return logger"""
    logger = logging.getLogger("urlens")
    logger.setLevel(logging.DEBUG if settings.DEBUG else logging.INFO)
    
    # Console handler
    handler = logging.StreamHandler(sys.stdout)
    handler.setLevel(logging.DEBUG if settings.DEBUG else logging.INFO)
    
    # Formatter
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    handler.setFormatter(formatter)
    
    logger.addHandler(handler)
    return logger


logger = setup_logger()
