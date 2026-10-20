Conversation Log
backend build the frontend using flutter /dart communicating properly with the backend and the files are properly distributed 
📱 DhuanRadar Flutter Frontend Built & Integrated

The complete frontend application has been built in Flutter & Dart in your project directory C:\dev\flutter_projects\dhuanrader (and synced with c:\Users\utkar\OneDrive\Attachments\Desktop\backend\frontend).

It follows a clean, production-grade layered architecture with seamless communication to your FastAPI backend.

📂 File Structure & Distribution
lib/
├── main.dart                       # App entry point, MultiProvider & Material 3 Theme
├── constants/
│   ├── api_constants.dart          # Base URLs (Android 10.0.2.2, Web/Desktop localhost, runtime override)
│   └── app_colors.dart             # Risk & Confidence colors matching ByteForge deck tokens
├── models/
│   ├── briefing_model.dart         # BriefingResponse, ScoringDetails, ExposureArea, UITheme
│   ├── weather_model.dart          # WeatherData, WindVector (10m Open-Meteo)
│   ├── hotspot_model.dart          # Hotspot, HotspotSummary (NASA FIRMS / Sample CSV)
│   ├── advisory_model.dart         # AdvisoryModel (TinyFish official health guidance)
│   └── report_model.dart           # FieldReport, DownwindRelayAlert
├── services/
│   └── api_service.dart            # HTTP client for FastAPI endpoints with error resilience
├── providers/
│   ├── briefing_provider.dart      # State management for briefings, regions & English/Hindi toggle
│   └── report_provider.dart        # State management for one-tap ground checks & downwind relay
├── widgets/
│   ├── risk_card.dart              # Main Risk & Confidence card with explainable reason & next steps
│   ├── exposure_area_card.dart     # Coarse area radar diagram (Slide 3: "Coarse area, not a smoke path")
│   ├── weather_wind_card.dart      # 10m wind speed, direction, & calm air notice (<5 km/h)
│   ├── official_advisory_card.dart # TinyFish verified advisory card with source link & disclaimer
│   ├── downwind_relay_card.dart    # Unverified downwind relay alert banner (Slide 7)
│   ├── ground_check_bar.dart       # One-tap field report bar ("Fire nearby", "Heavy smoke", etc.)
│   └── language_toggle.dart        # English / Hindi (En / अ) switcher
└── screens/
    ├── home_screen.dart            # Main container with ASHA/ANM header & Bottom Navigation Bar
    ├── briefing_tab.dart           # The primary Evening Briefing screen (Slides 1–6)
    ├── reports_tab.dart            # Ground checks & field feedback history (Slide 7)
    └── info_tab.dart               # Rules engine transparency (Slide 5 Example A & B) & connection settings
🌟 Key Features & Deck Alignment

Evening Smoke Briefing (Slides 1–6):

Village Selector: Pre-configured agricultural locations (Samana Cluster, Ludhiana Rural, Sangrur Farm Cluster, Karnal Block, North Delhi Outskirts).
Explainable Risk & Confidence: Color-coded badges with exact point breakdowns and transparent reasons.
Health Worker's Next Step: Highlights actionable community guidance (e.g., "Share the dated official advisory with the village. Watch field reports").
Exposure Area Visual: Coarse area circle diagram with hotspot counts within 25 km and 50 km.
10m Wind & Weather: Live wind speed, direction, and calm air notice from Open-Meteo.
Official Health Advisory: Formatted card displaying TinyFish validated advisories (MoHFW/NCDC) with medical disclaimers.

One-Tap Ground Checks (Slide 7):

Floating interactive chips:
🔥 Fire nearby
💨 Heavy smoke
🌫️ Smoke seen
✅ No smoke
Automatically logs field observations to the FastAPI backend (POST /api/v1/reports).

Downwind Relay Alerts (Slide 7):

If an upwind village logs a "Fire nearby" or "Heavy smoke" observation and wind data confirms smoke transport, downstream health workers receive an Unverified Downwind Relay Alert.

Bilingual UI (Hindi / English):

Tap the En / अ button in the top bar to toggle between English and Hindi across the entire UI.

Cross-Platform Networking Configured:

android/app/src/main/AndroidManifest.xml has been updated with android.permission.INTERNET and android:usesCleartextTraffic="true".
ApiConstants automatically detects whether the app is running on Android emulator (http://10.0.2.2:8000) or Web/Desktop/iOS (http://localhost:8000), with an in-app URL settings editor in the System Rules tab.
🚀 How to Run Backend & Frontend Together
Step 1: Start the FastAPI Backend

Open a terminal in c:\Users\utkar\OneDrive\Attachments\Desktop\backend (or C:\dev\flutter_projects\dhuanrader\backend):

bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

(Backend documentation will be available at http://localhost:8000/docs)

Step 2: Run the Flutter App

Open a terminal in C:\dev\flutter_projects\dhuanrader:

bash
# To run on Chrome (Web):
flutter run -d chrome
# To run on Windows Desktop:
flutter run -d windows
# Or to run on Android Emulator / Physical Device:
flutter run
Step 3: Run Flutter Tests
bash
flutter test

All widget tests and initial rendering tests pass.

INFO:     Started reloader process [20736] using StatReload
ERROR:    Error loading ASGI app. Could not import module "main".
INFO:     Stopping reloader process [20736]
(.venv) PS C:\dev\flutter_projects\dhuanrader\backend> uvicorn main:app --reload       
INFO:     Will watch for changes in these directories: ['C:\\dev\\flutter_projects\\dhuanrader\\backend']
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
INFO:     Started reloader process [34120] using StatReload
ERROR:    Error loading ASGI app. Could not import module "main".
INFO:     Stopping reloader process [34120]
(.venv) PS C:\dev\flutter_projects\dhuanrader\backend> identify the error 
create a readme file 
🔍 Error Identification

The error occurred:

ERROR: Error loading ASGI app. Could not import module "main".

because you ran:

bash
uvicorn main:app --reload

In your project structure, main.py is inside the app/ directory (app/main.py), rather than in the root of backend/. Uvicorn therefore searched for a file named main.py in the current working directory and could not find it.

✅ Solution

Run Uvicorn by pointing to the app package path:

bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

Once started:

Interactive OpenAPI / Swagger Docs: http://localhost:8000/docs
Direct Briefing Endpoint: http://localhost:8000/briefing?lat=30.3421&lon=76.3812
System Health Diagnostics: http://localhost:8000/api/v1/health
📄 Comprehensive README Created

A complete Master README.md has been created. It covers:

Quick Fix Section: Highlights the Uvicorn command syntax.
Step-by-Step Execution Guide:
Starting the FastAPI backend with .venv and Uvicorn.
Running the Flutter frontend on Chrome (flutter run -d chrome), Windows desktop, or Android emulator.
Architecture & File Distribution: Detailed layout of both backend/ and Flutter lib/.
Data Reality & Sources:
NASA FIRMS: Live API + bundled sample CSV fallback (app/data/sample_firms_hotspots.csv).
Open-Meteo: 10m wind speed, direction, and calm air detection.
TinyFish Search → Fetch: Safe health advisory extraction.
Rules Engine Verification: Slide 5 Example A and Example B unit tests breakdown.
Field Reports & Downwind Relay: One-tap ground checks and unverified relay safeguards.
# 🌫️ DhuanRadar - Full Stack System (FastAPI + Flutter)
> **From Fire Detection to Local Smoke Awareness**  
> *Tonight’s possible smoke risk, how sure we are, and the next step for ASHA/ANM workers.*  
> **Team ByteForge:** Nidhish Gupta · Bitthal Bhai Vinayak · Utkarsh Trivedi
---
## ⚡ Quick Fix for Common Startup Error
If you encountered:
```
ERROR: Error loading ASGI app. Could not import module "main".
```
**Cause**: The FastAPI application file is located inside the `app/` folder (`app/main.py`), not directly at the root of `backend/`.  
**Solution**: Always specify `app.main:app` instead of `main:app`:
```bash
# Correct command:
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
---
## 📌 Project Overview
Fire detection satellites (such as NASA FIRMS) detect hotspots, while central pollution agencies (CPCB, SAFAR) report city-wide AQI. However, **rural health workers (ASHA/ANM) have never had a same-day, village-level smoke briefing with stated confidence and actionable next steps**.
**DhuanRadar** bridges this gap:
1. **Data Inputs:** NASA FIRMS fire hotspots + Open-Meteo real-time 10m wind vectors + TinyFish official health advisories.
2. **Transparent Rules Engine (Slides 4 & 5):** Generates explainable **Risk** (`Low`, `Moderate`, `High`, `Unknown`), **Confidence** (`Low`, `Medium`, `High`), and transparent point breakdowns (no black-box AI).
3. **Official Health Advisories (Slide 6):** Retrieved safely via TinyFish Search & Fetch pipeline without blocking briefing latency.
4. **ASHA Feedback & Downwind Relay (Slide 7):** One-tap field reports ("Fire nearby", "Heavy smoke", "Smoke seen", "No smoke") relayed to downwind villages as unverified heads-up alerts.
5. **Flutter Frontend:** Interactive bilingual UI (English / Hindi), offline resilience, location presets, and one-tap ground check logging.
---
## 🏗️ Project Architecture & Directory Structure
```
├── backend/
│   ├── app/
│   │   ├── main.py                     # FastAPI app, CORS, root /briefing endpoint
│   │   ├── core/
│   │   │   ├── config.py               # Pydantic Settings & environment configuration
