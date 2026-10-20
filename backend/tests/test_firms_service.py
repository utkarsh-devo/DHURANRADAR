import pytest
from app.services.firms_service import firms_service
from app.services.weather_service import calculate_haversine_distance_km

@pytest.mark.asyncio
async def test_firms_sample_csv_fallback():
    """Verify that when no API key is provided, firms_service uses bundled sample CSV."""
    summary = await firms_service.get_hotspots(
        lat=30.3421,
        lon=76.3812,
        radius_km=50.0,
        freshness_hours=48.0,
        force_sample=True
    )
    assert summary.data_source == "BUNDLED_SAMPLE_CSV"
    assert summary.total_found > 0
    # Spot check distance ordering
    for i in range(len(summary.hotspots) - 1):
        assert summary.hotspots[i].distance_km <= summary.hotspots[i+1].distance_km

def test_haversine_distance_calculation():
    # Distance between Patiala (approx 30.34, 76.38) and Ludhiana (approx 30.90, 75.85) is ~80 km
    dist = calculate_haversine_distance_km(30.34, 76.38, 30.90, 75.85)
    assert 70.0 < dist < 95.0
