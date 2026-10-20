class WindVector {
  final double speedKmh;
  final double directionDeg;
  final String compassDirection;
  final bool isCalm;
  final double blowsTowardsDeg;

  WindVector({
    required this.speedKmh,
    required this.directionDeg,
    required this.compassDirection,
    required this.isCalm,
    required this.blowsTowardsDeg,
  });

  factory WindVector.fromJson(Map<String, dynamic> json) {
    return WindVector(
      speedKmh: (json['speed_kmh'] as num?)?.toDouble() ?? 0.0,
      directionDeg: (json['direction_deg'] as num?)?.toDouble() ?? 0.0,
      compassDirection: json['compass_direction'] as String? ?? 'N',
      isCalm: json['is_calm'] as bool? ?? false,
      blowsTowardsDeg: (json['blows_towards_deg'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class WeatherData {
  final double? temperatureC;
  final double? humidityPercent;
  final WindVector wind;
  final bool isReliable;
  final String dataSource;

  WeatherData({
    this.temperatureC,
    this.humidityPercent,
    required this.wind,
    required this.isReliable,
    required this.dataSource,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperatureC: (json['temperature_c'] as num?)?.toDouble(),
      humidityPercent: (json['humidity_percent'] as num?)?.toDouble(),
      wind: WindVector.fromJson(json['wind'] as Map<String, dynamic>? ?? {}),
      isReliable: json['is_reliable'] as bool? ?? true,
      dataSource: json['data_source'] as String? ?? 'Open-Meteo',
    );
  }
}
