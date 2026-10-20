import pytest
from app.schemas.report import FieldReportCreate, FieldReportType
from app.schemas.weather import WeatherData, WindVector
from app.services.report_service import report_service

def test_submit_and_list_field_report():
    report_in = FieldReportCreate(
        worker_id="ASHA-HR-009",
        worker_role="ASHA",
        village_name="Karnal Sector 4",
        latitude=29.6857,
        longitude=76.9905,
        report_type=FieldReportType.HEAVY_SMOKE,
        notes="Heavy smoke observed drifting from northern fields"
    )
    created = report_service.submit_report(report_in)
    assert created.id.startswith("rpt-")
    assert created.report_label_en == "Heavy smoke"
    assert created.report_label_hi == "घना धुआं"
    assert created.eligible_for_relay is True

    # Check listing
    recent = report_service.get_recent_reports(lat=29.6857, lon=76.9905, radius_km=20.0)
    assert any(r.id == created.id for r in recent)

def test_downwind_relay_trigger():
    """
    Test that a 'Heavy smoke' report upwind triggers downwind relay
    when wind blows towards the target village.
    """
    # Target village at (30.00, 76.50)
    target_lat = 30.00
    target_lon = 76.50

    # Fire reported at (30.15, 76.50) - directly North of target village (~16 km)
    report_in = FieldReportCreate(
        worker_id="ASHA-PB-777",
        village_name="North Field Village",
        latitude=30.15,
        longitude=76.50,
        report_type=FieldReportType.FIRE_NEARBY,
        notes="Burning near canal"
    )
    report_service.submit_report(report_in)

    # Wind blowing from North (0 deg) to South (180 deg) towards target village
    weather_blowing_south = WeatherData(
        temperature_c=27.0,
        humidity_percent=40.0,
        wind=WindVector(
            speed_kmh=15.0,
            direction_deg=0.0,
            compass_direction="N",
            is_calm=False,
            blows_towards_deg=180.0
        ),
        is_reliable=True
    )

    alert = report_service.check_downwind_relay(
        village_lat=target_lat,
        village_lon=target_lon,
        weather=weather_blowing_south
    )

    assert alert.active is True
    assert alert.status_label == "Unverified"
    assert "Unverified field alert" in alert.message
    assert "North Field Village" in alert.message
