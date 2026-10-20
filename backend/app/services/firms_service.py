import csv
import io
from datetime import datetime, timedelta, timezone
from typing import List, Optional, Tuple
import httpx

from app.core.config import settings
from app.core.logging import logger
from app.schemas.hotspot import Hotspot, HotspotSummary
from app.services.weather_service import calculate_haversine_distance_km, calculate_bearing_deg

class FirmsService:
    def __init__(self):
        self.map_key = settings.FIRMS_MAP_KEY
        self.source = settings.FIRMS_SOURCE
        self.sample_csv_path = settings.SAMPLE_FIRMS_CSV_PATH

    async def get_hotspots(
        self,
        lat: float,
        lon: float,
        radius_km: float = 50.0,
        freshness_hours: float = 24.0,
        force_sample: bool = False
    ) -> HotspotSummary:
        """
        Fetches hotspots near (lat, lon) within radius_km.
        Uses NASA FIRMS API if key is available, else falls back to bundled sample CSV.
        """
        raw_csv_text = None
        data_source = "BUNDLED_SAMPLE_CSV"

        # Try live NASA FIRMS API if key provided and not forced to sample
        if self.map_key and not force_sample:
            raw_csv_text = await self._fetch_live_firms(lat, lon, radius_km)
            if raw_csv_text:
                data_source = "NASA_FIRMS_API"

        # Fallback to bundled sample CSV
        if not raw_csv_text:
            raw_csv_text = self._read_sample_csv()
            data_source = "BUNDLED_SAMPLE_CSV"

        if not raw_csv_text:
            return HotspotSummary(
                total_found=0,
                fresh_count=0,
                within_25km_count=0,
                within_50km_count=0,
                hotspots=[],
                data_source=data_source,
                is_data_stale=True,
                monitoring_window_status="Satellite monitoring window expired / Coarse area unavailable"
            )

        hotspots = self._parse_csv(raw_csv_text, lat, lon, radius_km, freshness_hours)
        fresh_hotspots = [h for h in hotspots if h.is_fresh]
        within_25km = [h for h in fresh_hotspots if h.distance_km <= 25.0]
        within_50km = [h for h in fresh_hotspots if h.distance_km <= 50.0]

        is_stale = len(hotspots) > 0 and len(fresh_hotspots) == 0
        window_status = (
            "Satellite monitoring window expired / Coarse area unavailable"
            if (is_stale or len(hotspots) == 0)
            else "Active"
        )

        return HotspotSummary(
            total_found=len(hotspots),
            fresh_count=len(fresh_hotspots),
            within_25km_count=len(within_25km),
            within_50km_count=len(within_50km),
            hotspots=fresh_hotspots if len(fresh_hotspots) > 0 else hotspots,
            data_source=data_source,
            is_data_stale=is_stale,
            monitoring_window_status=window_status
        )

    async def _fetch_live_firms(self, lat: float, lon: float, radius_km: float) -> Optional[str]:
        # Approximate 1 deg ~ 111 km
        delta_deg = (radius_km / 111.0) * 1.2
        min_lon = round(lon - delta_deg, 4)
        min_lat = round(lat - delta_deg, 4)
        max_lon = round(lon + delta_deg, 4)
        max_lat = round(lat + delta_deg, 4)
        area_box = f"{min_lon},{min_lat},{max_lon},{max_lat}"

        url = f"https://firms.modaps.eosdis.nasa.gov/api/area/csv/{self.map_key}/{self.source}/{area_box}/1"
        try:
            async with httpx.AsyncClient(timeout=6.0) as client:
                resp = await client.get(url)
                if resp.status_code == 200 and "latitude" in resp.text:
                    logger.info("Successfully fetched live NASA FIRMS hotspots")
                    return resp.text
                else:
                    logger.warning(f"NASA FIRMS API returned status {resp.status_code}: {resp.text[:100]}")
                    return None
        except Exception as e:
            logger.warning(f"Error fetching live NASA FIRMS: {e}")
            return None

    def _read_sample_csv(self) -> Optional[str]:
        try:
            if self.sample_csv_path.exists():
                return self.sample_csv_path.read_text(encoding="utf-8")
        except Exception as e:
            logger.error(f"Failed to read bundled sample CSV at {self.sample_csv_path}: {e}")
        return None

    def _parse_csv(
        self,
        csv_text: str,
        target_lat: float,
        target_lon: float,
        radius_km: float,
        freshness_hours: float
    ) -> List[Hotspot]:
        hotspots: List[Hotspot] = []
        now = datetime.now(timezone.utc)
        freshness_cutoff = now - timedelta(hours=freshness_hours)

        reader = csv.DictReader(io.StringIO(csv_text))
        for row in reader:
            try:
                lat = float(row.get("latitude", 0))
                lon = float(row.get("longitude", 0))
                dist = calculate_haversine_distance_km(target_lat, target_lon, lat, lon)
                
                # Check spatial radius
                if dist > radius_km:
                    continue

                bearing = calculate_bearing_deg(target_lat, target_lon, lat, lon)
                acq_date = row.get("acq_date", "")
                acq_time = row.get("acq_time", "")
                confidence = row.get("confidence", "nominal")
                brightness = float(row["bright_ti4"]) if "bright_ti4" in row and row["bright_ti4"] else None
                frp = float(row["frp"]) if "frp" in row and row["frp"] else None

                # Freshness check
                is_fresh = True
                try:
                    if acq_date and acq_time:
                        time_str = acq_time.zfill(4)
                        obs_dt = datetime.strptime(f"{acq_date} {time_str}", "%Y-%m-%d %H%M").replace(tzinfo=timezone.utc)
                        if obs_dt < freshness_cutoff:
                            is_fresh = False
                except Exception:
                    is_fresh = True

                hotspots.append(Hotspot(
                    latitude=lat,
                    longitude=lon,
                    brightness=brightness,
                    confidence=confidence,
                    acq_date=acq_date,
                    acq_time=acq_time,
                    frp=frp,
                    distance_km=dist,
                    bearing_deg=bearing,
                    is_fresh=is_fresh
                ))
            except Exception as e:
                logger.debug(f"Row parse error: {e}")
                continue

        hotspots.sort(key=lambda h: h.distance_km)
        return hotspots

firms_service = FirmsService()
