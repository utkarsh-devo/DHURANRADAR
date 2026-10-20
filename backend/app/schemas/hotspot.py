from typing import List, Optional
from pydantic import BaseModel, Field

class Hotspot(BaseModel):
    latitude: float
    longitude: float
    brightness: Optional[float] = None
    confidence: str = "nominal"
    acq_date: str
    acq_time: str
    frp: Optional[float] = None # Fire Radiative Power (MW)
    distance_km: float = Field(..., description="Distance from target village/location in km")
    bearing_deg: float = Field(..., description="Bearing angle from target location to hotspot in degrees")
    is_fresh: bool = Field(True, description="Whether hotspot falls inside the freshness window")

class HotspotSummary(BaseModel):
    total_found: int = Field(0, description="Total hotspots found in search area")
    fresh_count: int = Field(0, description="Count of recent hotspots within freshness window")
    within_25km_count: int = 0
    within_50km_count: int = 0
    hotspots: List[Hotspot] = []
    data_source: str = Field("BUNDLED_SAMPLE_CSV", description="NASA_FIRMS_API or BUNDLED_SAMPLE_CSV")
    is_data_stale: bool = False
    monitoring_window_status: str = Field(
        "Active",
        description="'Active' or 'Satellite monitoring window expired / Coarse area unavailable'"
    )
