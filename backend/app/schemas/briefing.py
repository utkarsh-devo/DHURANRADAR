from typing import List, Optional
from enum import Enum
from pydantic import BaseModel, Field
from datetime import datetime, timezone

from app.schemas.weather import WeatherData
from app.schemas.hotspot import HotspotSummary
from app.schemas.advisory import AdvisoryResponse
from app.schemas.report import DownwindRelayAlert

class RiskLevel(str, Enum):
    LOW = "Low"
    MODERATE = "Moderate"
    HIGH = "High"
    UNKNOWN = "Unknown"

class ConfidenceLevel(str, Enum):
    LOW = "Low"
    MEDIUM = "Medium"
    HIGH = "High"

class ScoringDetails(BaseModel):
    hotspot_points: Optional[int] = Field(None, description="Points scored from nearby hotspots")
    wind_direction_points: Optional[int] = Field(None, description="Points scored from wind direction towards area")
    total_points: Optional[int] = Field(None, description="Total points (N/A if Unknown)")

class ExposureArea(BaseModel):
    area_type: str = "Coarse area (village / cluster)"
    center_lat: float
    center_lon: float
    radius_km: float = 25.0
    label: str = "Coarse area, not a smoke path"
    label_hi: str = "मोटा क्षेत्र (सटीक धुआं पथ नहीं)"

class UITheme(BaseModel):
    risk_color_hex: str
    risk_bg_hex: str
    risk_icon: str
    confidence_color_hex: str

class BriefingResponse(BaseModel):
    village_name: str = "Sample Village"
    latitude: float
    longitude: float
    briefing_time: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    
    # Core outputs (Slide 3 & 4)
    risk_level: RiskLevel
    risk_level_hi: str
    confidence: ConfidenceLevel
    confidence_hi: str
    
    # Explainability (Slide 4)
    reason: str
    reason_hi: str
    next_step: str
    next_step_hi: str
    key_data_gaps: List[str] = []
    
    # Rule scoring transparent breakdown (Slide 5)
    scoring: ScoringDetails
    
    # Supporting signal details
    satellite_coverage_status: str = "Active"
    exposure_area: ExposureArea
    weather: Optional[WeatherData] = None
    hotspots: HotspotSummary
    official_advisory: AdvisoryResponse
    relay_alert: Optional[DownwindRelayAlert] = None
    
    # Ready for Flutter UI
    ui_theme: UITheme
    
    disclaimer: str = (
        "Health guidance comes only from official advisories. "
        "DhuanRadar does not give medical advice. "
        "No alert ≠ no smoke. Data is limited. Use your own observation and official guidance."
    )
