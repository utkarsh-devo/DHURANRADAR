import 'package:flutter/material.dart';

class AppColors {
  // Brand & Theme
  static const Color primaryDark = Color(0xFF102A43);
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color accentTeal = Color(0xFF0D9488);
  static const Color ashaPink = Color(0xFFD946EF);
  
  // Backgrounds & Surface
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardSurface = Colors.white;
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  // Risk Colors
  static const Color riskLow = Color(0xFF16A34A);
  static const Color riskLowBg = Color(0xFFDCFCE7);
  
  static const Color riskModerate = Color(0xFFF59E0B);
  static const Color riskModerateBg = Color(0xFFFEF3C7);
  
  static const Color riskHigh = Color(0xFFDC2626);
  static const Color riskHighBg = Color(0xFFFEE2E2);
  
  static const Color riskUnknown = Color(0xFF64748B);
  static const Color riskUnknownBg = Color(0xFFF1F5F9);

  static Color getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
        return riskLow;
      case 'moderate':
        return riskModerate;
      case 'high':
        return riskHigh;
      default:
        return riskUnknown;
    }
  }

  static Color getRiskBgColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
        return riskLowBg;
      case 'moderate':
        return riskModerateBg;
      case 'high':
        return riskHighBg;
      default:
        return riskUnknownBg;
    }
  }
}
