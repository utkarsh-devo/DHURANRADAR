import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../constants/app_colors.dart';

class WeatherWindCard extends StatelessWidget {
  final WeatherData? weather;
  final bool isHindi;

  const WeatherWindCard({
    super.key,
    required this.weather,
    required this.isHindi,
  });

  @override
  Widget build(BuildContext context) {
    if (weather == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off, size: 20, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Text(
              isHindi ? "मौसम डेटा अनुपलब्ध (Open-Meteo)" : "Weather data unavailable (Open-Meteo)",
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    final wind = weather!.wind;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.air, size: 20, color: Color(0xFF0284C7)),
                  const SizedBox(width: 8),
                  Text(
                    isHindi ? "हवा और मौसम (10m Open-Meteo)" : "Wind & Weather (10m Open-Meteo)",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              if (wind.isCalm)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Text(
                    isHindi ? "शांत हवा" : "Calm Air",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // Wind speed & direction
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHindi ? "हवा की गति और दिशा" : "Wind Speed & Direction",
                        style: const TextStyle(fontSize: 10, color: Color(0xFF0369A1)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.navigation,
                            size: 16,
                            color: const Color(0xFF0284C7),
                            // Rotated to wind direction
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${wind.speedKmh} km/h · ${wind.compassDirection} (${wind.directionDeg.toInt()}°)",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0C4A6E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Temperature & Humidity
              if (weather!.temperatureC != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHindi ? "तापमान" : "Temp",
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${weather!.temperatureC!.toInt()}°C",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          if (wind.isCalm) ...[
            const SizedBox(height: 8),
            Text(
              isHindi
                  ? "हवा शांत (< 5 किमी/घंटा): धुआं एक ही जगह इकट्ठा हो सकता है।"
                  : "Calm air (< 5 km/h): considered separately, not proof of smoke transport.",
              style: const TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: Color(0xFFB45309),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
