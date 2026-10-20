# 🌫️ DhuanRadar - Backend API

> **From Fire Detection to Local Smoke Awareness**  
> *Tonight’s possible smoke risk, how sure we are, and the next step for ASHA/ANM workers.*  
> **Team ByteForge:** Nidhish Gupta · Bitthal Bhai Vinayak · Utkarsh Trivedi

---

## 📌 Project Overview

Fire detection satellites (such as NASA FIRMS) detect hotspots, while central pollution agencies (CPCB, SAFAR) report city-wide AQI. However, **rural health workers (ASHA/ANM) have never had a same-day, village-level smoke briefing with stated confidence and actionable next steps**.

**DhuanRadar** bridges this gap:
1. **Inputs:** NASA FIRMS fire hotspots + Open-Meteo real-time wind vectors (10m) + TinyFish official health advisories.
2. **Transparent Rules Engine:** Generates explainable **Risk** (`Low`, `Moderate`, `High`, `Unknown`), **Confidence** (`Low`, `Medium`, `High`), and transparent point breakdowns (no black-box AI).
3. **Official Advisory:** Retrieved safely via TinyFish Search & Fetch pipeline without blocking briefing latency.
4. **ASHA Feedback & Downwind Relay:** One-tap field reports ("Fire nearby", "Heavy smoke", "Smoke seen", "No smoke") relayed to downwind villages as unverified heads-up alerts.
5. **Mobile-Ready:** Built in FastAPI with full CORS support and bilingual (English + Hindi) fields ready for seamless Flutter integration.

---

## 🏗️ Project Architecture & Directory Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py                     # FastAPI app, CORS, lifespan, root /briefing endpoint
│   ├── core/
│   │   ├── __init__.py
│   │   ├── config.py               # Pydantic Settings & environment configuration
│   │   └── logging.py              # Structured logging
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── briefing.py             # BriefingResponse, RiskLevel, ConfidenceLevel, ExposureArea, UITheme
│   │   ├── weather.py              # WeatherData, WindVector
│   │   ├── hotspot.py              # Hotspot, HotspotSummary
│   │   ├── advisory.py             # AdvisoryResponse, AdvisoryStatus
│   │   └── report.py               # FieldReportCreate, FieldReportResponse, DownwindRelayAlert
│   ├── services/
│   │   ├── __init__.py
│   │   ├── rules_engine.py         # Slide 4 & 5 Rule Engine (points, data gaps, next steps)
│   │   ├── weather_service.py      # Open-Meteo integration, Haversine & wind transport calculations
│   │   ├── firms_service.py        # NASA FIRMS live API + bundled sample CSV fallback
│   │   ├── tinyfish_service.py     # TinyFish Search -> Fetch -> Validate pipeline
│   │   ├── report_service.py       # Ground check reports & downwind relay alerting
│   │   └── briefing_service.py     # Orchestrator aggregating signals into briefing response
│   ├── api/
│   │   ├── __init__.py
│   │   └── v1/
│   │       ├── __init__.py
│   │       ├── router.py           # API v1 aggregator
│   │       └── endpoints/
│   │           ├── briefing.py     # GET /api/v1/briefing
│   │           ├── reports.py      # POST & GET /api/v1/reports
│   │           ├── relay.py        # GET /api/v1/relay
│   │           ├── advisory.py     # GET /api/v1/advisory
│   │           └── health.py       # GET /api/v1/health
│   └── data/
│       └── sample_firms_hotspots.csv # Bundled Punjab/Haryana/Delhi fire observations
├── tests/
│   ├── test_rules_engine.py        # Slide 5 Example A & B Unit Tests
│   ├── test_briefing_api.py        # /briefing endpoint tests
│   ├── test_firms_service.py       # Hotspot parsing & spatial calculations
│   ├── test_reports_relay.py       # Field feedback & downwind relay tests
│   └── test_tinyfish.py            # Advisory retrieval & fallback tests
├── .env.example                    # Environment variable template
├── .env                            # Active environment configuration
├── requirements.txt                # Python dependencies
└── README.md
```

---

## ⚡ Quick Start

### 1. Requirements
- Python 3.10+
- pip

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Run Development Server
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
- Interactive Swagger UI: `http://localhost:8000/docs`
- Direct Briefing: `http://localhost:8000/briefing?lat=30.3421&lon=76.3812`
- Health Status: `http://localhost:8000/api/v1/health`

### 4. Run Unit Tests
```bash
pytest tests/ -v
```

---

## 🛰️ NASA FIRMS & Bundled Sample Data

> [!NOTE]
> **Sample Data Bundled for Instant Out-of-the-Box Execution**:
> NASA FIRMS requires a free `MAP_KEY` from [NASA Earthdata](https://firms.modaps.eosdis.nasa.gov/api/map_key/).
> To ensure the backend runs immediately without requiring an API key, **a realistic sample CSV is bundled at `app/data/sample_firms_hotspots.csv`** containing VIIRS satellite hotspot detections across Punjab, Haryana, and Delhi NCR.
>
> When `FIRMS_MAP_KEY` is provided in `.env`, the backend automatically calls the live NASA FIRMS API. If the key is omitted or the network call fails, the system automatically falls back to the bundled sample CSV.

---

## 🎣 TinyFish Advisory: Search → Fetch Pipeline

As specified in **Slide 6** (*"TinyFish: verified advisories, fetched safely"*):
1. **Search:** TinyFish finds official health and air quality pages (MoHFW, CPCB, NCDC).
2. **Fetch:** TinyFish pulls the full page content from the top URLs.
3. **Validate:** FastAPI checks approved government domains (`mohfw.gov.in`, `cpcb.nic.in`, `ncdc.gov.in`), date freshness, and relevance.
4. **Resilience:** *"Briefing never waits on advisory retrieval."*
   - Asynchronous execution with a short timeout and in-memory cache guarantees sub-500ms response times.
   - If an advisory cannot be retrieved or is unavailable, the briefing continues seamlessly and displays: `"No current verified advisory retrieved."`

---

## 📐 Transparent Rules Engine (Slide 4 & 5 Verification)

The rules engine does not use a black box. It maps clear signals to explainable points:

| Signal | Proposed Rule | Effect |
| :--- | :--- | :--- |
| **Nearby hotspots** | Recent observations within distance bands (0–25 km, 25–50 km) | +1 point per hotspot (Raise risk) |
| **Wind direction** | Towards the area, if reliable weather data confirms it | +1 point (Raise risk) |
| **Calm air** | Low wind speed (< 5 km/h) | Considered separately (potential smoke build-up), not proof of transport |
| **Stale or missing data** | Satellite data older than freshness window, missing wind data | Lowers confidence. No valid hotspots → Risk **Unknown** |

### Verified Deck Unit Tests (`tests/test_rules_engine.py`):

#### **Example A (Slide 5)**:
- **Observation:** 2 nearby hotspots (+2 points), Wind direction uncertain (0 points).
- **Total Points:** 2
- **Resulting Risk:** `MODERATE` (2–3 points)
- **Key Data Gaps:** Wind direction uncertain, weather data incomplete.
- **Resulting Confidence:** `LOW` (2 data gaps: High → Medium → Low)
- **Next Step:** *"Share the dated official advisory with the village. Watch field reports."*

#### **Example B (Slide 5)**:
- **Observation:** No valid recent hotspot data (satellite data older than freshness window) → N/A, Wind direction unknown → N/A.
- **Total Points:** N/A (`None`)
- **Resulting Risk:** `UNKNOWN` (Cannot assess)
- **Key Data Gaps:** Satellite data older than freshness window, weather data missing.
- **Resulting Confidence:** `LOW`
- **Next Step:** *"Data is limited. No alert ≠ no smoke. Use your own observation and official guidance."*

---

## 🌐 API Endpoints Reference

### 1. `GET /briefing` (and `GET /api/v1/briefing`)
**Query Parameters:**
- `lat` (float, required): Village latitude (e.g. `30.3421`)
- `lon` (float, required): Village longitude (e.g. `76.3812`)
- `village_name` (string, optional): Village name (e.g. `"Samana Cluster"`)
- `radius_km` (float, default: `50.0`): Search radius
- `freshness_hours` (float, default: `24.0`): Freshness window

**Sample Response:**
```json
{
  "village_name": "Samana Cluster",
  "latitude": 30.3421,
  "longitude": 76.3812,
  "briefing_time": "2026-10-20T14:45:00Z",
  "risk_level": "Moderate",
  "risk_level_hi": "मध्यम (Moderate)",
  "confidence": "Low",
  "confidence_hi": "निम्न (Low)",
  "reason": "Moderate smoke risk (2 points). Wind direction uncertain, weather data incomplete.",
  "reason_hi": "मध्यम धुआं जोखिम (2 अंक)। मौसम या हवा की दिशा अनिश्चित है, लेकिन पास में 2 या अधिक सक्रिय हॉटस्पॉट हैं।",
  "next_step": "Share the dated official advisory with the village. Watch field reports.",
  "next_step_hi": "गांव के साथ दिनांकित आधिकारिक सलाह साझा करें। जमीनी रिपोर्टों पर नज़र रखें।",
  "key_data_gaps": [
    "Weather data incomplete or missing",
    "Wind direction uncertain"
  ],
  "scoring": {
    "hotspot_points": 2,
    "wind_direction_points": 0,
    "total_points": 2
  },
  "exposure_area": {
    "area_type": "Coarse area (village / cluster)",
    "center_lat": 30.3421,
    "center_lon": 76.3812,
    "radius_km": 25.0,
    "label": "Coarse area, not a smoke path",
    "label_hi": "मोटा क्षेत्र, न कि सटीक धुआं पथ"
  },
  "official_advisory": {
    "status": "VERIFIED",
    "title": "MoHFW/NCDC Health Advisory on Air Pollution & Smoke",
    "summary": "Updated 2025 health advisory advises state health systems and community workers...",
    "issued_date": "1 Nov 2025",
    "source_name": "MoHFW/NCDC (NPCCHH)",
    "notice": "Official source and dated"
  },
  "ui_theme": {
    "risk_color_hex": "#FB8C00",
    "risk_bg_hex": "#FFF3E0",
    "risk_icon": "alert-triangle",
    "confidence_color_hex": "#D32F2F"
  },
  "disclaimer": "Health guidance comes only from official advisories. DhuanRadar does not give medical advice. No alert ≠ no smoke."
}
```

### 2. `POST /api/v1/reports`
Submit one-tap ground check from ASHA worker:
```json
{
  "worker_id": "ASHA-PB-042",
  "worker_role": "ASHA",
  "village_name": "Samana",
  "latitude": 30.3421,
  "longitude": 76.3812,
  "report_type": "FIRE_NEARBY",
  "notes": "Small residue fire observed along western field boundary"
}
```

### 3. `GET /api/v1/relay?lat=30.30&lon=76.38`
Checks if an unverified field report from an upwind village should be relayed to health workers in downwind areas.

### 4. `GET /api/v1/health`
Health check diagnostics returning active data source modes (Live vs Bundled Sample CSV, TinyFish, Open-Meteo).

---

## 📱 Flutter Frontend Integration Notes

When building the Flutter frontend:
- **Base URL for Android Emulator:** `http://10.0.2.2:8000`
- **Base URL for iOS Simulator / Web / Desktop:** `http://localhost:8000`
- **UI Themes Included in JSON:** `ui_theme.risk_color_hex` and `ui_theme.risk_icon` provide direct styling variables for Flutter cards.
- **Bilingual Support:** Every response contains pre-translated Hindi fields (`risk_level_hi`, `reason_hi`, `next_step_hi`, `summary_hi`) for rural ASHA workers.
- **CORS Configured:** Backend accepts cross-origin requests from any origin (`*`).
