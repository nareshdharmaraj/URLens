"""URLens Backend API - Main Application Entry Point"""
from fastapi import FastAPI
from app.config import settings
from app.core.middleware import setup_cors, setup_exception_handlers
from app.core.logger import logger
from app.api.v1.routes import router as api_v1_router

# Create FastAPI application
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="URLens API for universal web media downloading",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Setup middleware
setup_cors(app)
setup_exception_handlers(app)

# Include API routers
app.include_router(api_v1_router, prefix="/api/v1")


@app.get("/", tags=["root"])
async def root():
    """Root endpoint - Health check"""
    return {
        "name": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "status": "running",
        "environment": settings.ENVIRONMENT
    }


@app.get("/health", tags=["root"])
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn
    logger.info(f"Starting {settings.APP_NAME} on {settings.HOST}:{settings.PORT}")
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG
    )
