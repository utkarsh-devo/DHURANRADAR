from fastapi import APIRouter, Query
from app.schemas.report import DownwindRelayAlert
from app.services.report_service import report_service
from app.services.weather_service import weather_service

router = APIRouter()

@router.get(
    "/relay",
    response_model=DownwindRelayAlert,
    summary="Check Downwind Unverified Relay Alerts",
    description=(
        "Checks whether any recent 'Fire nearby' or 'Heavy smoke' field reports from upwind "
        "villages should be relayed to this location. Only active if wind data is recent and reliable."
    )
)
async def check_relay(
    lat: float = Query(..., ge=-90.0, le=90.0, description="Target village latitude"),
    lon: float = Query(..., ge=-180.0, le=180.0, description="Target village longitude")
) -> DownwindRelayAlert:
    weather, _ = await weather_service.get_current_weather(lat, lon)
    return report_service.check_downwind_relay(village_lat=lat, village_lon=lon, weather=weather)
