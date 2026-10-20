import 'package:flutter/material.dart';
import '../models/briefing_model.dart';
import '../constants/app_colors.dart';

class ExposureAreaCard extends StatelessWidget {
  final BriefingModel briefing;
  final bool isHindi;

  const ExposureAreaCard({
    super.key,
    required this.briefing,
    required this.isHindi,
  });

  @override
  Widget build(BuildContext context) {
    final area = briefing.exposureArea;
    final hotspots = briefing.hotspots;

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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.radar, size: 20, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    isHindi ? "संभावित जोखिम क्षेत्र (अनुमानित)" : "Potential exposure area (illustrative)",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${area.radiusKm.toInt()} km",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isHindi ? area.labelHi : area.label,
            style: const TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),

          // Visual Coarse Radar Representation
          Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF1F5F9),
                  const Color(0xFFE2E8F0).withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer circle
                Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.withOpacity(0.25), width: 1.5),
                  ),
                ),
                // Inner circle
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.08),
                    border: Border.all(color: Colors.blue.withOpacity(0.4), width: 1.5),
                  ),
                ),
                // Center village pin
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, size: 22, color: AppColors.riskHigh),
                    Text(
                      "Village",
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                  ],
                ),
                // Hotspot count badge overlay
                Positioned(
                  right: 12,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department, size: 14, color: Colors.deepOrange),
                        const SizedBox(width: 4),
                        Text(
                          "${hotspots.freshCount} ${isHindi ? 'सक्रिय हॉटस्पॉट' : 'hotspots'}",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Hotspots breakdown summary
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: isHindi ? "< 25 किमी में" : "Within 25 km",
                  value: "${hotspots.within25kmCount}",
                  icon: Icons.near_me_outlined,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  title: isHindi ? "< 50 किमी में" : "Within 50 km",
                  value: "${hotspots.within50kmCount}",
                  icon: Icons.all_out_outlined,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
