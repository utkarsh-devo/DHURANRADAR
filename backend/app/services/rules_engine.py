from typing import List, Optional, Tuple
from app.schemas.briefing import RiskLevel, ConfidenceLevel, ScoringDetails, UITheme
from app.schemas.hotspot import HotspotSummary
from app.schemas.weather import WeatherData
from app.services.weather_service import is_smoke_blowing_towards

class RulesEngine:
    """
    Transparent Rules Engine for DhuanRadar.
    Implements rules from Slide 4 & 5 of ByteForge deck.
    """

    @staticmethod
    def evaluate(
        hotspot_summary: Optional[HotspotSummary],
        weather: Optional[WeatherData],
        target_lat: float,
        target_lon: float
    ) -> Tuple[RiskLevel, ConfidenceLevel, ScoringDetails, List[str], str, str, str, str, UITheme]:
        """
        Evaluates signals and returns:
        (risk_level, confidence, scoring, key_data_gaps, reason, reason_hi, next_step, next_step_hi, ui_theme)
        """
        key_data_gaps: List[str] = []

        # Check Signal 1: Hotspot validity & freshness
        has_valid_hotspot_data = (
            hotspot_summary is not None
            and not hotspot_summary.is_data_stale
            and hotspot_summary.monitoring_window_status == "Active"
        )

        if hotspot_summary is None or hotspot_summary.is_data_stale or hotspot_summary.monitoring_window_status != "Active":
            key_data_gaps.append("Satellite data older than the freshness window")

        # Check Signal 2 & 3: Weather & Wind validity
        has_valid_weather = weather is not None and weather.is_reliable
        if not has_valid_weather:
            key_data_gaps.append("Weather data incomplete or missing")

        # --- RULE 1: If no valid recent hotspot data -> Risk UNKNOWN (Slide 4 & 5 Example B) ---
        if not has_valid_hotspot_data:
            confidence = RulesEngine._calculate_confidence(key_data_gaps)
            scoring = ScoringDetails(
                hotspot_points=None,
                wind_direction_points=None,
                total_points=None
            )
            reason = "Satellite data older than the freshness window, weather data missing." if len(key_data_gaps) > 1 else "Satellite data older than freshness window."
            reason_hi = "उपग्रह डेटा समय सीमा से पुराना है या मौसम डेटा अधूरा है। जोखिम का आकलन नहीं किया जा सकता।"
            next_step = "Data is limited. No alert ≠ no smoke. Use your own observation and official guidance."
            next_step_hi = "डेटा सीमित है। अलर्ट न होने का मतलब धुआं न होना नहीं है। अपने अवलोकन और आधिकारिक सलाह का उपयोग करें।"
            theme = RulesEngine._get_ui_theme(RiskLevel.UNKNOWN, confidence)
            return RiskLevel.UNKNOWN, confidence, scoring, key_data_gaps, reason, reason_hi, next_step, next_step_hi, theme

        # --- RULE 2: Calculate Points for Hotspots and Wind ---
        fresh_count = hotspot_summary.fresh_count
        within_25km = hotspot_summary.within_25km_count
        within_50km = hotspot_summary.within_50km_count

        # Hotspot points:
        # Example A: 2 nearby hotspots -> +2 points
        hotspot_points = fresh_count

        # Wind direction points:
        wind_direction_points = 0
        wind_towards_area = False
        wind_uncertain = False

        if not has_valid_weather:
            wind_uncertain = True
            key_data_gaps.append("Wind direction uncertain")
        else:
            if weather.wind.is_calm:
                # Calm air: low wind speed. Considered separately, not proof of smoke transport.
                wind_direction_points = 0
            else:
                # Check if wind blows smoke towards village from any hotspot
                for h in hotspot_summary.hotspots:
                    if is_smoke_blowing_towards(
                        h.latitude, h.longitude,
                        target_lat, target_lon,
                        weather.wind.blows_towards_deg
                    ):
                        wind_towards_area = True
                        break

                if wind_towards_area:
                    wind_direction_points = 1

        total_points = hotspot_points + wind_direction_points

        # --- RULE 3: Map Points to Risk Level ---
        if total_points >= 4:
            risk_level = RiskLevel.HIGH
        elif total_points >= 2:
            risk_level = RiskLevel.MODERATE
        else:
            risk_level = RiskLevel.LOW

        confidence = RulesEngine._calculate_confidence(key_data_gaps)
        scoring = ScoringDetails(
            hotspot_points=hotspot_points,
            wind_direction_points=wind_direction_points,
            total_points=total_points
        )

        # Build Explainable Reason
        reason, reason_hi = RulesEngine._generate_reasons(
            risk_level, hotspot_summary, weather, key_data_gaps, total_points
        )

        # Build Next Step Guidance (Slide 3)
        next_step, next_step_hi = RulesEngine._get_next_steps(risk_level)

        theme = RulesEngine._get_ui_theme(risk_level, confidence)
        return risk_level, confidence, scoring, key_data_gaps, reason, reason_hi, next_step, next_step_hi, theme

    @staticmethod
    def _calculate_confidence(data_gaps: List[str]) -> ConfidenceLevel:
        """
        Confidence logic (Slide 5):
        Base is HIGH.
        1 gap: High -> Medium
        2 or more gaps: High -> Medium -> Low
        """
        # Deduplicate gaps
        unique_gaps = list(set(data_gaps))
        gap_count = len(unique_gaps)
        if gap_count == 0:
            return ConfidenceLevel.HIGH
        elif gap_count == 1:
            return ConfidenceLevel.MEDIUM
        else:
            return ConfidenceLevel.LOW

    @staticmethod
    def _generate_reasons(
        risk: RiskLevel,
        hotspots: HotspotSummary,
        weather: Optional[WeatherData],
        gaps: List[str],
        points: int
    ) -> Tuple[str, str]:
        if risk == RiskLevel.HIGH:
            en = f"Multiple fire hotspots ({hotspots.fresh_count}) detected nearby with wind directing smoke towards village."
            hi = f"पास में कई आग के हॉटस्पॉट ({hotspots.fresh_count}) पाए गए हैं और हवा का रुख गांव की ओर धुआं ला रहा है।"
        elif risk == RiskLevel.MODERATE:
            if gaps:
                en = f"Moderate smoke risk ({points} points). Wind direction uncertain, weather data incomplete."
                hi = f"मध्यम धुआं जोखिम ({points} अंक)। मौसम या हवा की दिशा अनिश्चित है, लेकिन पास में 2 या अधिक सक्रिय हॉटस्पॉट हैं।"
            else:
                en = f"Moderate smoke risk ({points} points) detected with {hotspots.fresh_count} nearby hotspot(s) under observation."
                hi = f"मध्यम धुआं जोखिम ({points} अंक): निगरानी क्षेत्र में {hotspots.fresh_count} सक्रिय हॉटस्पॉट देखे गए हैं।"
        elif risk == RiskLevel.LOW:
            en = "Minimal fire activity detected within village radius. Clear or calm conditions."
            hi = "गांव के दायरे में नगण्य आग की गतिविधि। मौसम अनुकूल या शांत हवा।"
        else:
            en = "Insufficient data to assess risk. No alert does not mean no smoke."
            hi = "डेटा अपर्याप्त है। अलर्ट न होने का मतलब धुआं न होना नहीं है।"
        return en, hi

    @staticmethod
    def _get_next_steps(risk: RiskLevel) -> Tuple[str, str]:
        if risk == RiskLevel.HIGH:
            en = "Prioritise community communication this evening, guided by the official advisory."
            hi = "आधिकारिक सलाह के मार्गदर्शन में, आज शाम गांव में जागरूकता को प्राथमिकता दें।"
        elif risk == RiskLevel.MODERATE:
            en = "Share the dated official advisory with the village. Watch field reports."
            hi = "गांव के साथ दिनांकित आधिकारिक सलाह साझा करें। जमीनी रिपोर्टों पर नज़र रखें।"
        elif risk == RiskLevel.LOW:
            en = "Routine awareness. Check current official guidance."
            hi = "सामान्य जागरूकता। वर्तमान आधिकारिक दिशा-निर्देश देखें।"
        else: # UNKNOWN
            en = "Data is limited. No alert ≠ no smoke. Use your own observation and official guidance."
            hi = "डेटा सीमित है। अलर्ट न होने का मतलब धुआं न होना नहीं है। अपने अवलोकन और आधिकारिक सलाह का उपयोग करें।"
        return en, hi

    @staticmethod
    def _get_ui_theme(risk: RiskLevel, confidence: ConfidenceLevel) -> UITheme:
        theme_map = {
            RiskLevel.LOW: {
                "color": "#2E7D32", # Green
                "bg": "#E8F5E9",
                "icon": "check-circle",
            },
            RiskLevel.MODERATE: {
                "color": "#FB8C00", # Orange / Amber
                "bg": "#FFF3E0",
                "icon": "alert-triangle",
            },
            RiskLevel.HIGH: {
                "color": "#D32F2F", # Red
                "bg": "#FFEBEE",
                "icon": "alert-octagon",
            },
            RiskLevel.UNKNOWN: {
                "color": "#757575", # Neutral Grey
                "bg": "#F5F5F5",
                "icon": "help-circle",
            }
        }
        conf_color_map = {
            ConfidenceLevel.HIGH: "#2E7D32",
            ConfidenceLevel.MEDIUM: "#FB8C00",
            ConfidenceLevel.LOW: "#D32F2F",
        }
        item = theme_map[risk]
        return UITheme(
            risk_color_hex=item["color"],
            risk_bg_hex=item["bg"],
            risk_icon=item["icon"],
            confidence_color_hex=conf_color_map[confidence]
        )

rules_engine = RulesEngine()
