from typing import Dict, Any
from fastapi import APIRouter
from app.core.config import settings

router = APIRouter()

@router.get(
    "/health",
    summary="System Health & Data Source Diagnostics",
    description="Returns backend operational status, data sources configuration, and FIRMS mode (Live vs Sample)."
)
async def health_check() -> Dict[str, Any]:
    firms_mode = "Live NASA FIRMS API" if settings.FIRMS_MAP_KEY else "Bundled Sample CSV (Punjab/Haryana/Delhi NCR)"
    tinyfish_mode = "Live TinyFish Search/Fetch" if settings.TINYFISH_API_KEY else "Official MoHFW 2025 Advisory Baseline"
    
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "environment": "development" if settings.DEBUG else "production",
        "firms_hotspots": {
            "mode": firms_mode,
            "has_api_key": bool(settings.FIRMS_MAP_KEY),
            "source": settings.FIRMS_SOURCE,
            "sample_csv_exists": settings.SAMPLE_FIRMS_CSV_PATH.exists()
        },
        "weather": {
            "provider": "Open-Meteo",
            "type": "Free / Public (No Key Required)"
        },
        "tinyfish_advisory": {
            "mode": tinyfish_mode,
            "has_api_key": bool(settings.TINYFISH_API_KEY),
            "free_pipeline": "Search + Fetch"
        },
        "target_audience": "ASHA / ANM Village Health Workers",
        "mobile_ready": True
    }
