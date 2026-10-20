import 'package:flutter/material.dart';
import 'weather_model.dart';
import 'hotspot_model.dart';
import 'advisory_model.dart';
import 'report_model.dart';

class ScoringDetails {
  final int? hotspotPoints;
  final int? windDirectionPoints;
  final int? totalPoints;

  ScoringDetails({
    this.hotspotPoints,
    this.windDirectionPoints,
    this.totalPoints,
  });

  factory ScoringDetails.fromJson(Map<String, dynamic> json) {
    return ScoringDetails(
      hotspotPoints: json['hotspot_points'] as int?,
      windDirectionPoints: json['wind_direction_points'] as int?,
      totalPoints: json['total_points'] as int?,
    );
  }
}

class ExposureArea {
  final String areaType;
  final double centerLat;
  final double centerLon;
  final double radiusKm;
  final String label;
  final String labelHi;

  ExposureArea({
    required this.areaType,
    required this.centerLat,
    required this.centerLon,
    required this.radiusKm,
    required this.label,
    required this.labelHi,
  });

  factory ExposureArea.fromJson(Map<String, dynamic> json) {
    return ExposureArea(
      areaType: json['area_type'] as String? ?? 'Coarse area',
      centerLat: (json['center_lat'] as num?)?.toDouble() ?? 0.0,
      centerLon: (json['center_lon'] as num?)?.toDouble() ?? 0.0,
      radiusKm: (json['radius_km'] as num?)?.toDouble() ?? 25.0,
      label: json['label'] as String? ?? 'Coarse area, not a smoke path',
      labelHi: json['label_hi'] as String? ?? 'मोटा क्षेत्र (सटीक धुआं पथ नहीं)',
    );
  }
}

class UIThemeModel {
  final Color riskColor;
  final Color riskBgColor;
  final String riskIcon;
  final Color confidenceColor;

  UIThemeModel({
    required this.riskColor,
    required this.riskBgColor,
    required this.riskIcon,
    required this.confidenceColor,
  });

  factory UIThemeModel.fromJson(Map<String, dynamic> json) {
    Color parseHex(String? hexStr, Color fallback) {
      if (hexStr == null || hexStr.isEmpty) return fallback;
      try {
        final buffer = StringBuffer();
        if (hexStr.length == 6 || hexStr.length == 7) buffer.write('ff');
        buffer.write(hexStr.replaceFirst('#', ''));
        return Color(int.parse(buffer.toString(), radix: 16));
      } catch (_) {
        return fallback;
      }
    }

    return UIThemeModel(
      riskColor: parseHex(json['risk_color_hex'], const Color(0xFFF59E0B)),
      riskBgColor: parseHex(json['risk_bg_hex'], const Color(0xFFFEF3C7)),
      riskIcon: json['risk_icon'] as String? ?? 'alert-triangle',
      confidenceColor: parseHex(json['confidence_color_hex'], const Color(0xFFDC2626)),
    );
  }
}

class BriefingModel {
  final String villageName;
  final double latitude;
  final double longitude;
  final DateTime briefingTime;
  final String riskLevel;
  final String riskLevelHi;
  final String confidence;
  final String confidenceHi;
  final String reason;
  final String reasonHi;
  final String nextStep;
  final String nextStepHi;
  final List<String> keyDataGaps;
  final ScoringDetails scoring;
  final String satelliteCoverageStatus;
  final ExposureArea exposureArea;
  final WeatherData? weather;
  final HotspotSummary hotspots;
  final AdvisoryModel officialAdvisory;
  final DownwindRelayAlert? relayAlert;
  final UIThemeModel uiTheme;
  final String disclaimer;

  BriefingModel({
    required this.villageName,
    required this.latitude,
    required this.longitude,
    required this.briefingTime,
    required this.riskLevel,
    required this.riskLevelHi,
    required this.confidence,
    required this.confidenceHi,
    required this.reason,
    required this.reasonHi,
    required this.nextStep,
    required this.nextStepHi,
    required this.keyDataGaps,
    required this.scoring,
    required this.satelliteCoverageStatus,
    required this.exposureArea,
    this.weather,
    required this.hotspots,
    required this.officialAdvisory,
    this.relayAlert,
    required this.uiTheme,
    required this.disclaimer,
  });

  factory BriefingModel.fromJson(Map<String, dynamic> json) {
    return BriefingModel(
      villageName: json['village_name'] as String? ?? 'Village / Cluster',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      briefingTime: DateTime.tryParse(json['briefing_time'] as String? ?? '') ?? DateTime.now(),
      riskLevel: json['risk_level'] as String? ?? 'Unknown',
      riskLevelHi: json['risk_level_hi'] as String? ?? 'अज्ञात',
      confidence: json['confidence'] as String? ?? 'Low',
      confidenceHi: json['confidence_hi'] as String? ?? 'निम्न',
      reason: json['reason'] as String? ?? '',
      reasonHi: json['reason_hi'] as String? ?? '',
      nextStep: json['next_step'] as String? ?? '',
      nextStepHi: json['next_step_hi'] as String? ?? '',
      keyDataGaps: (json['key_data_gaps'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      scoring: ScoringDetails.fromJson(json['scoring'] as Map<String, dynamic>? ?? {}),
      satelliteCoverageStatus: json['satellite_coverage_status'] as String? ?? 'Active',
      exposureArea: ExposureArea.fromJson(json['exposure_area'] as Map<String, dynamic>? ?? {}),
      weather: json['weather'] != null ? WeatherData.fromJson(json['weather'] as Map<String, dynamic>) : null,
      hotspots: HotspotSummary.fromJson(json['hotspots'] as Map<String, dynamic>? ?? {}),
      officialAdvisory: AdvisoryModel.fromJson(json['official_advisory'] as Map<String, dynamic>? ?? {}),
      relayAlert: json['relay_alert'] != null ? DownwindRelayAlert.fromJson(json['relay_alert'] as Map<String, dynamic>) : null,
      uiTheme: UIThemeModel.fromJson(json['ui_theme'] as Map<String, dynamic>? ?? {}),
      disclaimer: json['disclaimer'] as String? ?? '',
    );
  }
}
