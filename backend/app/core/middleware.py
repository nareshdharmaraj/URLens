"""Middleware configuration"""
from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from app.config import settings
from app.core.logger import logger
from app.core.exceptions import (
    URLensException,
    UnsupportedURLException,
    PrivateContentException,
    ExtractionException,
    NetworkException
)


def setup_cors(app: FastAPI) -> None:
    """Configure CORS middleware"""
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_origin_regex=r"https?://localhost(:\d+)?",
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )


def setup_exception_handlers(app: FastAPI) -> None:
    """Configure exception handlers"""
    
    @app.exception_handler(UnsupportedURLException)
    async def unsupported_url_handler(request: Request, exc: UnsupportedURLException):
        logger.error(f"Unsupported URL: {str(exc)}")
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content={"detail": f"Error processing URL: Unsupported URL - {str(exc)}"}
        )
    
    @app.exception_handler(PrivateContentException)
    async def private_content_handler(request: Request, exc: PrivateContentException):
        logger.error(f"Private content: {str(exc)}")
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content={"detail": f"Error processing URL: Private or Restricted Content - {str(exc)}"}
        )
    
    @app.exception_handler(ExtractionException)
    async def extraction_handler(request: Request, exc: ExtractionException):
        logger.error(f"Extraction error: {str(exc)}")
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content={"detail": f"Error processing URL: {str(exc)}"}
        )
    
    @app.exception_handler(NetworkException)
    async def network_handler(request: Request, exc: NetworkException):
        logger.error(f"Network error: {str(exc)}")
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={"detail": f"Network error: {str(exc)}"}
        )
    
    @app.exception_handler(Exception)
    async def general_exception_handler(request: Request, exc: Exception):
        logger.error(f"Unexpected error: {str(exc)}", exc_info=True)
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={"detail": "An unexpected error occurred"}
        )
