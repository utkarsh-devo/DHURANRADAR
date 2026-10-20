import math
from typing import Optional, Tuple
import httpx
from datetime import datetime, timezone

from app.core.config import settings
from app.core.logging import logger
from app.schemas.weather import WeatherData, WindVector

COMPASS_DIRECTIONS = [
    "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
    "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"
]

def deg_to_compass(deg: float) -> str:
    val = int((deg / 22.5) + 0.5)
    return COMPASS_DIRECTIONS[val % 16]

def calculate_haversine_distance_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculates geodesic distance between two points in km."""
    R = 6371.0 # Earth's radius in km
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (math.sin(dlat / 2) ** 2 +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
         math.sin(dlon / 2) ** 2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return round(R * c, 2)

def calculate_bearing_deg(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculates initial bearing (in degrees, 0-360) from point 1 to point 2."""
    dlon = math.radians(lon2 - lon1)
    y = math.sin(dlon) * math.cos(math.radians(lat2))
    x = (math.cos(math.radians(lat1)) * math.sin(math.radians(lat2)) -
         math.sin(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.cos(dlon))
    bearing = (math.degrees(math.atan2(y, x)) + 360) % 360
    return round(bearing, 1)

def is_smoke_blowing_towards(
    fire_lat: float, fire_lon: float,
    village_lat: float, village_lon: float,
    wind_blows_towards_deg: float,
    tolerance_deg: float = 45.0
) -> bool:
    """
    Checks if smoke from fire coordinate is transported towards village coordinate.
    Vector from fire -> village has bearing theta.
    Wind blows towards wind_blows_towards_deg.
    If absolute angular difference <= tolerance_deg, smoke moves towards village.
    """
    bearing_fire_to_village = calculate_bearing_deg(fire_lat, fire_lon, village_lat, village_lon)
    diff = abs(bearing_fire_to_village - wind_blows_towards_deg)
    diff = min(diff, 360 - diff)
    return diff <= tolerance_deg

class WeatherService:
    def __init__(self):
        self.base_url = settings.OPEN_METEO_BASE_URL

    async def get_current_weather(self, lat: float, lon: float) -> Tuple[Optional[WeatherData], bool]:
        """
        Fetches real-time weather from Open-Meteo.
        Returns (WeatherData, is_complete).
        If API fails, returns (None, False).
        """
        params = {
            "latitude": lat,
            "longitude": lon,
            "current": "temperature_2m,relative_humidity_2m,wind_speed_10m,wind_direction_10m",
            "timezone": "auto"
        }
        try:
            async with httpx.AsyncClient(timeout=4.0) as client:
                resp = await client.get(self.base_url, params=params)
                if resp.status_code == 200:
                    data = resp.json()
                    curr = data.get("current", {})
                    wind_speed = float(curr.get("wind_speed_10m", 0.0))
                    wind_direction = float(curr.get("wind_direction_10m", 0.0))
                    is_calm = wind_speed < settings.CALM_WIND_THRESHOLD_KMH
                    blows_towards = (wind_direction + 180.0) % 360.0

                    vector = WindVector(
                        speed_kmh=round(wind_speed, 1),
                        direction_deg=round(wind_direction, 1),
                        compass_direction=deg_to_compass(wind_direction),
                        is_calm=is_calm,
                        blows_towards_deg=round(blows_towards, 1)
                    )
                    weather = WeatherData(
                        temperature_c=curr.get("temperature_2m"),
                        humidity_percent=curr.get("relative_humidity_2m"),
                        wind=vector,
                        is_reliable=True,
                        data_source="Open-Meteo",
                        timestamp=datetime.now(timezone.utc)
                    )
                    return weather, True
                else:
                    logger.warning(f"Open-Meteo returned status {resp.status_code}")
                    return None, False
        except Exception as e:
            logger.warning(f"Failed to fetch Open-Meteo weather: {e}")
            return None, False

weather_service = WeatherService()
