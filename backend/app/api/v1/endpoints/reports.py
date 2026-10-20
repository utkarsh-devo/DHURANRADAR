from typing import List, Optional
from fastapi import APIRouter, Query, status
from app.schemas.report import FieldReportCreate, FieldReportResponse
from app.services.report_service import report_service

router = APIRouter()

@router.post(
    "/reports",
    response_model=FieldReportResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Submit Field Report (ASHA/ANM)",
    description=(
        "Allows registered ASHA/ANM workers to submit one-tap ground check reports: "
        "'Fire nearby', 'Heavy smoke', 'Smoke seen', or 'No smoke'. "
        "Reports are marked 'Unverified' as a heads-up for downwind areas."
    )
)
async def submit_field_report(report_in: FieldReportCreate) -> FieldReportResponse:
    return report_service.submit_report(report_in)

@router.get(
    "/reports",
    response_model=List[FieldReportResponse],
    summary="List Recent Ground Check Reports",
    description="Retrieve recent field check reports within an optional radius."
)
async def list_reports(
    lat: Optional[float] = Query(None, description="Optional center latitude"),
    lon: Optional[float] = Query(None, description="Optional center longitude"),
    radius_km: float = Query(50.0, ge=1.0, le=200.0, description="Radius in km"),
    limit: int = Query(50, ge=1, le=200, description="Max reports to retrieve")
) -> List[FieldReportResponse]:
    return report_service.get_recent_reports(lat=lat, lon=lon, radius_km=radius_km, limit=limit)
