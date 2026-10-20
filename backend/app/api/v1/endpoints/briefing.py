from typing import Optional
from fastapi import APIRouter, Query, HTTPException
from app.schemas.briefing import BriefingResponse
from app.services.briefing_service import briefing_service

router = APIRouter()

@router.get(
    "/briefing",
    response_model=BriefingResponse,
    summary="Generate Evening Smoke Briefing",
    description=(
        "Core briefing endpoint for ASHA/ANM workers. Combines NASA FIRMS hotspots, "
        "Open-Meteo wind vectors, and TinyFish verified health advisory to calculate "
        "transparent risk level, confidence, explainable reason, and actionable next steps."
    )
)
async def get_briefing(
    lat: float = Query(..., ge=-90.0, le=90.0, description="Village / location latitude (e.g. 30.3421)"),
    lon: float = Query(..., ge=-180.0, le=180.0, description="Village / location longitude (e.g. 76.3812)"),
    village_name: Optional[str] = Query(None, description="Village or cluster name for display in app"),
    radius_km: Optional[float] = Query(50.0, ge=5.0, le=200.0, description="Search radius in kilometers"),
    freshness_hours: Optional[float] = Query(24.0, ge=1.0, le=72.0, description="Satellite data freshness window in hours")
) -> BriefingResponse:
    try:
        return await briefing_service.generate_briefing(
            lat=lat,
            lon=lon,
            village_name=village_name,
            radius_km=radius_km,
            freshness_hours=freshness_hours
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate briefing: {str(e)}")
