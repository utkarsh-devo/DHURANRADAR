from typing import Optional
from fastapi import FastAPI, Query, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.core.config import settings
from app.core.logging import logger
from app.api.v1.router import api_router
from app.schemas.briefing import BriefingResponse
from app.services.briefing_service import briefing_service

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info(f"Starting {settings.PROJECT_NAME}...")
    logger.info(f"FIRMS API Mode: {'LIVE API' if settings.FIRMS_MAP_KEY else 'BUNDLED SAMPLE CSV'}")
    logger.info(f"TinyFish Mode: {'LIVE API' if settings.TINYFISH_API_KEY else 'OFFICIAL BASELINE GUIDANCE'}")
    yield
    logger.info("Shutting down DhuanRadar backend...")

app = FastAPI(
    title="DhuanRadar API",
    description=(
        "**DhuanRadar: From Fire Detection to Local Smoke Awareness**\n\n"
        "Built for ASHA/ANM health workers in rural Punjab, Haryana, and North India.\n\n"
        "### Key Capabilities:\n"
        "- **Evening Smoke Briefing**: Evaluates NASA FIRMS fire hotspots + Open-Meteo wind data via transparent rules.\n"
        "- **Explainable Output**: Distinct Risk, Confidence, Data gaps, and health worker's next steps.\n"
        "- **Official Advisories**: Safe, verified advisories retrieved via TinyFish Search & Fetch.\n"
        "- **Ground Truth Feedback**: ASHA workers submit one-tap field checks ('Fire nearby', 'Heavy smoke', 'Smoke seen', 'No smoke').\n"
        "- **Downwind Relay**: Alerts downwind villages when reliable wind data indicates smoke transport.\n"
        "- **Flutter Ready**: Built with clean JSON schemas, bilingual Hindi/English fields, and CORS for mobile app integration."
    ),
    version="1.0.0",
    lifespan=lifespan
)

# CORS Middleware for Flutter Web and Mobile Emulators
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API v1 Router
app.include_router(api_router, prefix=settings.API_V1_STR)

# Top-level direct endpoint as requested: /briefing?lat=&lon=
@app.get(
    "/briefing",
    response_model=BriefingResponse,
    tags=["Briefing"],
    summary="Direct Briefing Endpoint (/briefing?lat=&lon=)"
)
async def direct_briefing(
    lat: float = Query(..., ge=-90.0, le=90.0, description="Village latitude (e.g. 30.3421)"),
    lon: float = Query(..., ge=-180.0, le=180.0, description="Village longitude (e.g. 76.3812)"),
    village_name: Optional[str] = Query("Sample Region", description="Name of village or cluster"),
    radius_km: Optional[float] = Query(50.0, ge=5.0, le=200.0, description="Radius in km"),
    freshness_hours: Optional[float] = Query(24.0, ge=1.0, le=72.0, description="Freshness window in hours")
) -> BriefingResponse:
    """Direct root-level briefing endpoint for quick testing and lightweight Flutter mobile requests."""
    try:
        return await briefing_service.generate_briefing(
            lat=lat,
            lon=lon,
            village_name=village_name,
            radius_km=radius_km,
            freshness_hours=freshness_hours
        )
    except Exception as e:
        logger.error(f"Error in direct /briefing: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/", tags=["Health & Status"])
async def root():
    return {
        "project": "DhuanRadar",
        "tagline": "From Fire Detection to Local Smoke Awareness",
        "team": "ByteForge (Nidhish Gupta, Bitthal Bhai Vinayak, Utkarsh Trivedi)",
        "docs_url": "/docs",
        "quick_briefing_example": "/briefing?lat=30.3421&lon=76.3812",
        "health_check": "/api/v1/health"
    }
