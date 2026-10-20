import pytest
from app.schemas.briefing import RiskLevel, ConfidenceLevel
from app.schemas.hotspot import Hotspot, HotspotSummary
from app.schemas.weather import WeatherData, WindVector
from app.services.rules_engine import rules_engine

def test_deck_slide5_example_a():
    """
    Unit Test for Slide 5: Example A (illustrative)
    Inputs:
      - Nearby hotspots: 2 nearby hotspots (+2 points)
      - Wind direction: Direction uncertain (0 points)
    Expected Outputs:
      - Total points: 2
      - Resulting risk level: MODERATE (2-3)
      - Key data gaps: Wind direction uncertain, weather data incomplete.
      - Resulting confidence: LOW (2 data gaps: High -> Medium -> Low)
    """
    # 2 nearby hotspots
    hotspots = [
        Hotspot(
            latitude=30.34, longitude=76.38, brightness=330.0,
            acq_date="2026-10-20", acq_time="1345", distance_km=12.0,
            bearing_deg=45.0, is_fresh=True
        ),
        Hotspot(
            latitude=30.36, longitude=76.40, brightness=340.0,
            acq_date="2026-10-20", acq_time="1346", distance_km=18.0,
            bearing_deg=50.0, is_fresh=True
        )
    ]
    summary = HotspotSummary(
        total_found=2,
        fresh_count=2,
        within_25km_count=2,
        within_50km_count=2,
        hotspots=hotspots,
        data_source="BUNDLED_SAMPLE_CSV",
        is_data_stale=False,
        monitoring_window_status="Active"
    )

    # Weather data incomplete / wind direction uncertain
    weather = None # Missing/uncertain weather data

    risk, confidence, scoring, gaps, reason, reason_hi, next_step, next_step_hi, theme = rules_engine.evaluate(
        hotspot_summary=summary,
        weather=weather,
        target_lat=30.3421,
        target_lon=76.3812
    )

    # Verify Slide 5 Example A results exactly
    assert risk == RiskLevel.MODERATE, f"Expected MODERATE, got {risk}"
    assert scoring.hotspot_points == 2, f"Expected 2 hotspot points, got {scoring.hotspot_points}"
    assert scoring.wind_direction_points == 0, f"Expected 0 wind points, got {scoring.wind_direction_points}"
    assert scoring.total_points == 2, f"Expected total points 2, got {scoring.total_points}"
    assert confidence == ConfidenceLevel.LOW, f"Expected LOW confidence due to 2 data gaps, got {confidence}"
    
    # Check data gaps
    assert any("weather" in g.lower() for g in gaps)
    assert any("wind" in g.lower() for g in gaps)
    assert "MODERATE" in reason or "2" in reason or "moderate" in reason.lower()
    assert "Share the dated official advisory" in next_step


def test_deck_slide5_example_b():
    """
    Unit Test for Slide 5: Example B (illustrative)
    Inputs:
      - Nearby hotspots: No valid recent hotspot data (satellite data older than freshness window) -> N/A
      - Wind direction: Direction unknown -> N/A
    Expected Outputs:
      - Total points: N/A (None)
      - Resulting risk level: UNKNOWN (Cannot assess)
      - Key data gaps: Satellite data older than freshness window, weather data missing.
      - Resulting confidence: LOW (2 data gaps: High -> Medium -> Low)
      - Next step guidance: 'Data is limited. No alert ≠ no smoke. Use your own observation and official guidance.'
    """
    # Stale hotspot data (satellite data older than freshness window)
    stale_summary = HotspotSummary(
        total_found=5,
        fresh_count=0, # No valid recent hotspots
        within_25km_count=0,
        within_50km_count=0,
        hotspots=[],
        data_source="BUNDLED_SAMPLE_CSV",
        is_data_stale=True,
        monitoring_window_status="Satellite monitoring window expired / Coarse area unavailable"
    )

    # Weather data missing
    weather = None

    risk, confidence, scoring, gaps, reason, reason_hi, next_step, next_step_hi, theme = rules_engine.evaluate(
        hotspot_summary=stale_summary,
        weather=weather,
        target_lat=30.3421,
        target_lon=76.3812
    )

    # Verify Slide 5 Example B results exactly
    assert risk == RiskLevel.UNKNOWN, f"Expected UNKNOWN risk, got {risk}"
    assert scoring.total_points is None, f"Expected N/A total points, got {scoring.total_points}"
    assert scoring.hotspot_points is None
    assert scoring.wind_direction_points is None
    assert confidence == ConfidenceLevel.LOW, f"Expected LOW confidence, got {confidence}"

    # Check key data gaps
    assert any("satellite" in g.lower() for g in gaps)
    assert any("weather" in g.lower() for g in gaps)

    # Check next steps
    assert "No alert ≠ no smoke" in next_step
    assert "अलर्ट न होने का मतलब धुआं न होना नहीं है" in next_step_hi


def test_rules_engine_high_risk_scenario():
    """Test scenario with high fire activity and wind blowing towards target."""
    hotspots = [
        Hotspot(latitude=30.40, longitude=76.38, distance_km=8.0, bearing_deg=0.0, acq_date="2026-10-20", acq_time="1345", is_fresh=True),
        Hotspot(latitude=30.42, longitude=76.39, distance_km=10.0, bearing_deg=5.0, acq_date="2026-10-20", acq_time="1346", is_fresh=True),
        Hotspot(latitude=30.45, longitude=76.38, distance_km=13.0, bearing_deg=0.0, acq_date="2026-10-20", acq_time="1347", is_fresh=True),
        Hotspot(latitude=30.50, longitude=76.38, distance_km=18.0, bearing_deg=0.0, acq_date="2026-10-20", acq_time="1348", is_fresh=True),
    ]
    summary = HotspotSummary(
        total_found=4, fresh_count=4, within_25km_count=4, within_50km_count=4,
        hotspots=hotspots, is_data_stale=False, monitoring_window_status="Active"
    )

    # Wind blowing towards South (towards 180 deg) from North
    # Wind direction 0 deg (from North), blows_towards_deg = 180 deg
    weather = WeatherData(
        temperature_c=28.0,
        humidity_percent=45.0,
        wind=WindVector(speed_kmh=14.0, direction_deg=0.0, compass_direction="N", is_calm=False, blows_towards_deg=180.0),
        is_reliable=True
    )

    risk, confidence, scoring, gaps, reason, reason_hi, next_step, next_step_hi, theme = rules_engine.evaluate(
        hotspot_summary=summary, weather=weather, target_lat=30.30, target_lon=76.38
    )

    assert risk == RiskLevel.HIGH
    assert scoring.total_points >= 4
    assert confidence == ConfidenceLevel.HIGH
    assert "Prioritise community communication" in next_step


def test_rules_engine_low_risk_scenario():
    """Test scenario with zero or minimal hotspots and calm conditions."""
    summary = HotspotSummary(
        total_found=0, fresh_count=0, within_25km_count=0, within_50km_count=0,
        hotspots=[], is_data_stale=False, monitoring_window_status="Active"
    )
    weather = WeatherData(
        temperature_c=25.0,
        humidity_percent=50.0,
        wind=WindVector(speed_kmh=3.0, direction_deg=90.0, compass_direction="E", is_calm=True, blows_towards_deg=270.0),
        is_reliable=True
    )

    risk, confidence, scoring, gaps, reason, reason_hi, next_step, next_step_hi, theme = rules_engine.evaluate(
        hotspot_summary=summary, weather=weather, target_lat=30.3421, target_lon=76.3812
    )

    assert risk == RiskLevel.LOW
    assert scoring.total_points == 0
    assert confidence == ConfidenceLevel.HIGH
    assert "Routine awareness" in next_step
