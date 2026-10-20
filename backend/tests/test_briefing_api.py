import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_root_endpoint():
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["project"] == "DhuanRadar"
    assert "ByteForge" in data["team"]

def test_direct_briefing_endpoint():
    """Test direct MVP endpoint: /briefing?lat=30.3421&lon=76.3812"""
    response = client.get("/briefing?lat=30.3421&lon=76.3812&village_name=Samana")
    assert response.status_code == 200
    data = response.json()
    
    # Check essential response fields
    assert "risk_level" in data
    assert "confidence" in data
    assert "reason" in data
    assert "reason_hi" in data
    assert "next_step" in data
    assert "next_step_hi" in data
    assert "scoring" in data
    assert "exposure_area" in data
    assert "official_advisory" in data
    assert "ui_theme" in data

    # Check Flutter UI metadata
    assert "risk_color_hex" in data["ui_theme"]
    assert "risk_icon" in data["ui_theme"]

    # Check official advisory (Slide 6)
    assert data["official_advisory"]["status"] in ["VERIFIED", "SOURCE_UNAVAILABLE"]
    assert "DhuanRadar does not give medical advice" in data["disclaimer"]

def test_api_v1_briefing_endpoint():
    """Test /api/v1/briefing endpoint"""
    response = client.get("/api/v1/briefing?lat=28.7041&lon=77.1025&village_name=Narela")
    assert response.status_code == 200
    data = response.json()
    assert data["village_name"] == "Narela"
    assert data["latitude"] == 28.7041
    assert data["longitude"] == 77.1025

def test_health_check_endpoint():
    """Test /api/v1/health endpoint"""
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "firms_hotspots" in data
    assert "tinyfish_advisory" in data
    assert data["mobile_ready"] is True
