from typing import Optional
from pydantic import BaseModel, Field
from datetime import datetime, timezone

class WindVector(BaseModel):
    speed_kmh: float = Field(..., description="Wind speed at 10m in km/h")
    direction_deg: float = Field(..., description="Wind direction in degrees (direction from which wind blows)")
    compass_direction: str = Field(..., description="Compass cardinal direction (e.g., NW, SSE)")
    is_calm: bool = Field(False, description="True if wind speed is below calm threshold (<5 km/h)")
    blows_towards_deg: float = Field(..., description="Direction towards which wind is blowing (direction_deg + 180 % 360)")

class WeatherData(BaseModel):
    temperature_c: Optional[float] = None
    humidity_percent: Optional[float] = None
    wind: WindVector
    is_reliable: bool = True
    data_source: str = "Open-Meteo"
    timestamp: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
