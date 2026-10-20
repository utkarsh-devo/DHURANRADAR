class Hotspot {
  final double latitude;
  final double longitude;
  final double? brightness;
  final String confidence;
  final String acqDate;
  final String acqTime;
  final double distanceKm;
  final double bearingDeg;
  final bool isFresh;

  Hotspot({
    required this.latitude,
    required this.longitude,
    this.brightness,
    required this.confidence,
    required this.acqDate,
    required this.acqTime,
    required this.distanceKm,
    required this.bearingDeg,
    required this.isFresh,
  });

  factory Hotspot.fromJson(Map<String, dynamic> json) {
    return Hotspot(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      brightness: (json['brightness'] as num?)?.toDouble(),
      confidence: json['confidence'] as String? ?? 'nominal',
      acqDate: json['acq_date'] as String? ?? '',
      acqTime: json['acq_time'] as String? ?? '',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      bearingDeg: (json['bearing_deg'] as num?)?.toDouble() ?? 0.0,
      isFresh: json['is_fresh'] as bool? ?? true,
    );
  }
}

class HotspotSummary {
  final int totalFound;
  final int freshCount;
  final int within25kmCount;
  final int within50kmCount;
  final List<Hotspot> hotspots;
  final String dataSource;
  final bool isDataStale;
  final String monitoringWindowStatus;

  HotspotSummary({
    required this.totalFound,
    required this.freshCount,
    required this.within25kmCount,
    required this.within50kmCount,
    required this.hotspots,
    required this.dataSource,
    required this.isDataStale,
    required this.monitoringWindowStatus,
  });

  factory HotspotSummary.fromJson(Map<String, dynamic> json) {
    final list = json['hotspots'] as List<dynamic>? ?? [];
    return HotspotSummary(
      totalFound: json['total_found'] as int? ?? 0,
      freshCount: json['fresh_count'] as int? ?? 0,
      within25kmCount: json['within_25km_count'] as int? ?? 0,
      within50kmCount: json['within_50km_count'] as int? ?? 0,
      hotspots: list.map((e) => Hotspot.fromJson(e as Map<String, dynamic>)).toList(),
      dataSource: json['data_source'] as String? ?? 'BUNDLED_SAMPLE_CSV',
      isDataStale: json['is_data_stale'] as bool? ?? false,
      monitoringWindowStatus: json['monitoring_window_status'] as String? ?? 'Active',
    );
  }
}
