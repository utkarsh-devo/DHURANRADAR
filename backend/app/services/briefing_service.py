import asyncio
from datetime import datetime, timezone
from typing import Optional

from app.core.config import settings
from app.core.logging import logger
from app.schemas.briefing import BriefingResponse, ExposureArea
from app.services.weather_service import weather_service
from app.services.firms_service import firms_service
from app.services.tinyfish_service import tinyfish_service
from app.services.rules_engine import rules_engine
from app.services.report_service import report_service

class BriefingService:
    async def generate_briefing(
        self,
        lat: float,
        lon: float,
        village_name: Optional[str] = None,
        radius_km: Optional[float] = None,
        freshness_hours: Optional[float] = None
    ) -> BriefingResponse:
        radius = radius_km or settings.DEFAULT_SEARCH_RADIUS_KM
        freshness = freshness_hours or settings.HOTSPOT_FRESHNESS_HOURS
        name = village_name or "Sample Village / Cluster"

        # Concurrently gather weather, hotspots, and official advisory
        # Slide 6: Briefing never waits on advisory retrieval
        weather_task = weather_service.get_current_weather(lat, lon)
        hotspots_task = firms_service.get_hotspots(lat, lon, radius_km=radius, freshness_hours=freshness)
        advisory_task = tinyfish_service.get_verified_advisory(state_or_district="Punjab")

        results = await asyncio.gather(
            weather_task,
            hotspots_task,
            advisory_task,
            return_exceptions=True
        )

        weather_res, _ = results[0] if not isinstance(results[0], Exception) else (None, False)
        hotspots = results[1] if not isinstance(results[1], Exception) else firms_service.get_hotspots(lat, lon, force_sample=True)
        advisory = results[2] if not isinstance(results[2], Exception) else tinyfish_service.get_default_official_advisory()

        # If hotspots is a coroutine (in case of fallback), await it
        if asyncio.iscoroutine(hotspots):
            hotspots = await hotspots

        # Evaluate transparent rules (Slides 4 & 5)
        (
            risk_level,
            confidence,
            scoring,
            key_data_gaps,
            reason,
            reason_hi,
            next_step,
            next_step_hi,
            ui_theme
        ) = rules_engine.evaluate(
            hotspot_summary=hotspots,
            weather=weather_res,
            target_lat=lat,
            target_lon=lon
        )

        # Check downwind field report relay (Slide 7)
        relay_alert = report_service.check_downwind_relay(
            village_lat=lat,
            village_lon=lon,
            weather=weather_res
        )

        exposure_area = ExposureArea(
            area_type="Coarse area (village / cluster)",
            center_lat=lat,
            center_lon=lon,
            radius_km=25.0,
            label="Coarse area, not a smoke path",
            label_hi="मोटा क्षेत्र, न कि सटीक धुआं पथ"
        )

        return BriefingResponse(
            village_name=name,
            latitude=lat,
            longitude=lon,
            briefing_time=datetime.now(timezone.utc),
            risk_level=risk_level,
            risk_level_hi=self._risk_level_hindi(risk_level),
            confidence=confidence,
            confidence_hi=self._confidence_hindi(confidence),
            reason=reason,
            reason_hi=reason_hi,
            next_step=next_step,
            next_step_hi=next_step_hi,
            key_data_gaps=key_data_gaps,
            scoring=scoring,
            satellite_coverage_status=hotspots.monitoring_window_status,
            exposure_area=exposure_area,
            weather=weather_res,
            hotspots=hotspots,
            official_advisory=advisory,
            relay_alert=relay_alert,
            ui_theme=ui_theme
        )

    def _risk_level_hindi(self, risk) -> str:
        mapping = {
            "Low": "कम (Low)",
            "Moderate": "मध्यम (Moderate)",
            "High": "उच्च (High)",
            "Unknown": "अज्ञात (Unknown)"
        }
        return mapping.get(str(risk.value if hasattr(risk, 'value') else risk), "अज्ञात")

    def _confidence_hindi(self, conf) -> str:
        mapping = {
            "Low": "निम्न (Low)",
            "Medium": "मध्यम (Medium)",
            "High": "उच्च (High)"
        }
        return mapping.get(str(conf.value if hasattr(conf, 'value') else conf), "निम्न")

briefing_service = BriefingService()
