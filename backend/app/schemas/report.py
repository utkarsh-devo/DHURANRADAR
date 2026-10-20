from typing import Optional
from enum import Enum
from pydantic import BaseModel, Field
from datetime import datetime, timezone

class FieldReportType(str, Enum):
    FIRE_NEARBY = "FIRE_NEARBY"
    HEAVY_SMOKE = "HEAVY_SMOKE"
    SMOKE_SEEN = "SMOKE_SEEN"
    NO_SMOKE = "NO_SMOKE"

class FieldReportCreate(BaseModel):
    worker_id: str = Field(..., description="ID of the registered ASHA/ANM worker (e.g. ASHA-PB-042)")
    worker_role: str = Field("ASHA", description="Role: ASHA, ANM, Village Health Team")
    village_name: Optional[str] = Field("Sample Village", description="Name of village/cluster")
    latitude: float = Field(..., description="Worker latitude")
    longitude: float = Field(..., description="Worker longitude")
    report_type: FieldReportType = Field(..., description="Quick one-tap observation")
    notes: Optional[str] = Field(None, description="Optional brief field notes")

class FieldReportResponse(BaseModel):
    id: str
    worker_id: str
    worker_role: str
    village_name: Optional[str]
    latitude: float
    longitude: float
    report_type: FieldReportType
    report_label_en: str
    report_label_hi: str
    notes: Optional[str]
    created_at: datetime
    verification_status: str = "Unverified (Heads-up, not an alarm)"
    eligible_for_relay: bool = False

class DownwindRelayAlert(BaseModel):
    active: bool = False
    source_report_id: Optional[str] = None
    report_type: Optional[FieldReportType] = None
    upwind_village: Optional[str] = None
    distance_km: Optional[float] = None
    message: str = "No upwind unverified field alerts."
    message_hi: str = "हवा के रुख की दिशा से कोई अपुष्ट अलर्ट नहीं है।"
    status_label: str = "Unverified"
    warning_note: str = "Always 'Unverified' (a heads up, not an alarm)."
