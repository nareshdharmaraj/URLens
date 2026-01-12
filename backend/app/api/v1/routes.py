"""Main API v1 router"""
from fastapi import APIRouter
from app.api.v1.endpoints import analyze, download

router = APIRouter()

# Include endpoint routers
router.include_router(analyze.router)
router.include_router(download.router)
