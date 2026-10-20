import uuid
from typing import List, Optional
from datetime import datetime, timedelta, timezone

from app.schemas.report import FieldReportCreate, FieldReportResponse, FieldReportType, DownwindRelayAlert
from app.schemas.weather import WeatherData
from app.services.weather_service import calculate_haversine_distance_km, is_smoke_blowing_towards
from app.core.logging import logger

REPORT_TYPE_LABELS = {
    FieldReportType.FIRE_NEARBY: ("Fire nearby", "पास में आग"),
    FieldReportType.HEAVY_SMOKE: ("Heavy smoke", "घना धुआं"),
    FieldReportType.SMOKE_SEEN: ("Smoke seen", "धुआं दिख रहा है"),
    FieldReportType.NO_SMOKE: ("No smoke", "धुआं नहीं है"),
}

class ReportService:
    def __init__(self):
        # In-memory store for reports (clean and ultra-fast for prototype)
        self._reports: List[FieldReportResponse] = []
        self._seed_sample_reports()

    def _seed_sample_reports(self):
        """Seed sample report for testing upwind relay logic."""
        now = datetime.now(timezone.utc)
        sample = FieldReportResponse(
            id="seed-report-001",
            worker_id="ASHA-PB-104",
            worker_role="ASHA",
            village_name="Samana Cluster",
            latitude=30.1500,
            longitude=76.1900,
            report_type=FieldReportType.FIRE_NEARBY,
            report_label_en="Fire nearby",
            report_label_hi="पास में आग",
            notes="Small field stubble fire observed near roadside",
            created_at=now - timedelta(minutes=45),
            verification_status="Unverified (Heads-up, not an alarm)",
            eligible_for_relay=True
        )
        self._reports.append(sample)

    def submit_report(self, report_in: FieldReportCreate) -> FieldReportResponse:
        report_id = f"rpt-{uuid.uuid4().hex[:8]}"
        en_label, hi_label = REPORT_TYPE_LABELS.get(
            report_in.report_type,
            (report_in.report_type.value, report_in.report_type.value)
        )
        is_relay_eligible = report_in.report_type in [
            FieldReportType.FIRE_NEARBY,
            FieldReportType.HEAVY_SMOKE
        ]

        report = FieldReportResponse(
            id=report_id,
            worker_id=report_in.worker_id,
            worker_role=report_in.worker_role,
            village_name=report_in.village_name or "Unknown Village",
            latitude=report_in.latitude,
            longitude=report_in.longitude,
            report_type=report_in.report_type,
            report_label_en=en_label,
            report_label_hi=hi_label,
            notes=report_in.notes,
            created_at=datetime.now(timezone.utc),
            verification_status="Unverified (Heads-up, not an alarm)",
            eligible_for_relay=is_relay_eligible
        )
        self._reports.append(report)
        logger.info(f"Field report submitted: {report_id} by {report.worker_id} ({report.report_type.value})")
        return report

    def get_recent_reports(
        self,
        lat: Optional[float] = None,
        lon: Optional[float] = None,
        radius_km: float = 50.0,
        limit: int = 50
    ) -> List[FieldReportResponse]:
        results = []
        for r in reversed(self._reports):
            if lat is not None and lon is not None:
                dist = calculate_haversine_distance_km(lat, lon, r.latitude, r.longitude)
                if dist <= radius_km:
                    results.append(r)
            else:
                results.append(r)
            if len(results) >= limit:
                break
        return results

    def check_downwind_relay(
        self,
        village_lat: float,
        village_lon: float,
        weather: Optional[WeatherData]
    ) -> DownwindRelayAlert:
        """
        Slide 7 Relay Logic:
        'A registered ASHA/ANM's "Fire nearby" or "Heavy smoke" report goes, marked Unverified,
        to health workers of coarse downwind areas. Only if wind data is recent and reliable.'
        """
        if not weather or not weather.is_reliable or weather.wind.is_calm:
            return DownwindRelayAlert(
                active=False,
                message="Wind data is calm or missing; downwind relay inactive.",
                message_hi="हवा शांत है या डेटा उपलब्ध नहीं है; डाउनविंड रिले निष्क्रिय है।"
            )

        cutoff = datetime.now(timezone.utc) - timedelta(hours=6)
        for r in reversed(self._reports):
            if r.created_at < cutoff or not r.eligible_for_relay:
                continue

            dist = calculate_haversine_distance_km(village_lat, village_lon, r.latitude, r.longitude)
            # Check within 40 km upwind radius
            if 0.5 < dist <= 40.0:
                is_upwind = is_smoke_blowing_towards(
                    fire_lat=r.latitude,
                    fire_lon=r.longitude,
                    village_lat=village_lat,
                    village_lon=village_lon,
                    wind_blows_towards_deg=weather.wind.blows_towards_deg,
                    tolerance_deg=50.0
                )
                if is_upwind:
                    en_label, hi_label = REPORT_TYPE_LABELS.get(r.report_type, (r.report_type.value, r.report_type.value))
                    return DownwindRelayAlert(
                        active=True,
                        source_report_id=r.id,
                        report_type=r.report_type,
                        upwind_village=r.village_name,
                        distance_km=dist,
                        message=(
                            f"Unverified field alert: '{en_label}' reported in coarse upwind area "
                            f"({r.village_name or 'Nearby cluster'}, {dist} km away). Wind is currently blowing toward your area."
                        ),
                        message_hi=(
                            f"अपुष्ट फील्ड अलर्ट: हवा के रुख की दिशा से ({r.village_name or 'निकटवर्ती क्लस्टर'}, "
                            f"{dist} किमी दूर) '{hi_label}' दर्ज किया गया है। हवा आपके क्षेत्र की ओर है।"
                        ),
                        status_label="Unverified",
                        warning_note="Always 'Unverified' (a heads up, not an alarm)."
                    )

        return DownwindRelayAlert(
            active=False,
            message="No active upwind unverified field alerts.",
            message_hi="हवा की दिशा में कोई सक्रिय अपुष्ट फील्ड अलर्ट नहीं है।"
        )

report_service = ReportService()
