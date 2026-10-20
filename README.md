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
## 📱 Field Feedback & Downwind Relay (Slide 7)
- **One-Tap Reporting:** Registered ASHA workers can log ground conditions (*"Fire nearby"*, *"Heavy smoke"*, *"Smoke seen"*, *"No smoke"*).
- **Downwind Relay:** When a *"Fire nearby"* or *"Heavy smoke"* report is logged upwind, downwind villages receive an **Unverified Downwind Relay Alert** if wind direction points towards them.
- **Safeguard:** Always marked *"Unverified (a heads up, not an alarm)"*.

