from pathlib import Path
from typing import List, Union
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import field_validator

BASE_DIR = Path(__file__).resolve().parent.parent.parent
DATA_DIR = BASE_DIR / "app" / "data"

class Settings(BaseSettings):
    PROJECT_NAME: str = "DhuanRadar - Smoke Awareness System"
    API_V1_STR: str = "/api/v1"
    DEBUG: bool = True

    # NASA FIRMS settings
    # Free map key from NASA Earthdata: https://firms.modaps.eosdis.nasa.gov/api/map_key/
    FIRMS_MAP_KEY: str = ""
    FIRMS_SOURCE: str = "VIIRS_SNPP_NRT"
    SAMPLE_FIRMS_CSV_PATH: Path = DATA_DIR / "sample_firms_hotspots.csv"

    # Open-Meteo settings (Free, no key needed)
    OPEN_METEO_BASE_URL: str = "https://api.open-meteo.com/v1/forecast"

    # TinyFish Advisory Search & Fetch settings
    TINYFISH_API_KEY: str = ""
    TINYFISH_BASE_URL: str = "https://api.tinyfish.io"

    # Rules Engine Default Thresholds (Slide 4 & 5)
    DEFAULT_SEARCH_RADIUS_KM: float = 50.0
    HOTSPOT_FRESHNESS_HOURS: float = 24.0
    CALM_WIND_THRESHOLD_KMH: float = 5.0 # Calm air: low wind speed
    DOWNWIND_ANGLE_TOLERANCE_DEG: float = 45.0 # Fire smoke direction cone

    # CORS origins for Flutter Web, iOS & Android
    CORS_ORIGINS: Union[List[str], str] = ["*"]

    @field_validator("CORS_ORIGINS", mode="before")
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> List[str]:
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",") if i.strip()]
        elif isinstance(v, list):
            return v
        return ["*"]

    model_config = SettingsConfigDict(
        env_file=str(BASE_DIR / ".env"),
        env_file_encoding="utf-8",
        extra="ignore"
    )

settings = Settings()
