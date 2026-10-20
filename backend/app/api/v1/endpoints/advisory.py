from fastapi import APIRouter, Query
from app.schemas.advisory import AdvisoryResponse
from app.services.tinyfish_service import tinyfish_service

router = APIRouter()

@router.get(
    "/advisory",
    response_model=AdvisoryResponse,
    summary="Get Verified Health Advisory (TinyFish)",
    description=(
        "Retrieves the latest verified official health advisory for the region. "
        "TinyFish Search & Fetch finds and extracts the advisory safely from official government portals."
    )
)
async def get_advisory(
    region: str = Query("Punjab", description="State or district name")
) -> AdvisoryResponse:
    return await tinyfish_service.get_verified_advisory(state_or_district=region)
