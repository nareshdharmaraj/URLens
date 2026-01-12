"""Main API v1 router"""

from fastapi import APIRouter
from app.api.v1.endpoints import analyze, download, proxy

router = APIRouter()

# Include endpoint routers
router.include_router(analyze.router)
router.include_router(download.router)
router.include_router(proxy.router)
