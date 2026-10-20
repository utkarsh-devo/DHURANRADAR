import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/briefing_provider.dart';
import '../providers/report_provider.dart';
import '../constants/app_colors.dart';

class GroundCheckBar extends StatelessWidget {
  const GroundCheckBar({super.key});

  @override
  Widget build(BuildContext context) {
    final briefingProvider = context.watch<BriefingProvider>();
    final reportProvider = context.watch<ReportProvider>();
    final isHindi = briefingProvider.isHindi;
    final region = briefingProvider.selectedRegion;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
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
              Text(
                isHindi ? "जमीनी जांच दर्ज करें (Log Ground Check)" : "Log Ground Check",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isHindi ? "टैप करके दर्ज करें" : "TAP TO RECORD",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isHindi
                ? "आपका त्वरित टैप उस समय मदद करता है जब उपग्रह बादलों से ढके हों।"
                : "Your real-time tap helps calibrate district support when satellites are obscured.",
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),

          // 4 One-tap chips
          Row(
            children: [
              Expanded(
                child: _buildTapChip(
                  context: context,
                  label: isHindi ? "धुआं दिख रहा" : "Smoke seen",
                  icon: Icons.cloud_outlined,
                  color: const Color(0xFF0284C7),
                  bgColor: const Color(0xFFF0F9FF),
                  type: "SMOKE_SEEN",
                  reportProvider: reportProvider,
                  region: region,
                  isHindi: isHindi,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTapChip(
                  context: context,
                  label: isHindi ? "घना धुआं" : "Heavy smoke",
                  icon: Icons.grain,
                  color: const Color(0xFFD97706),
                  bgColor: const Color(0xFFFFFBEB),
                  type: "HEAVY_SMOKE",
                  reportProvider: reportProvider,
                  region: region,
                  isHindi: isHindi,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTapChip(
                  context: context,
                  label: isHindi ? "धुआं नहीं है" : "No smoke",
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF16A34A),
                  bgColor: const Color(0xFFF0FDF4),
                  type: "NO_SMOKE",
                  reportProvider: reportProvider,
                  region: region,
                  isHindi: isHindi,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTapChip(
                  context: context,
                  label: isHindi ? "पास में आग" : "Fire nearby",
                  icon: Icons.local_fire_department,
                  color: const Color(0xFFDC2626),
                  bgColor: const Color(0xFFFEF2F2),
                  type: "FIRE_NEARBY",
                  reportProvider: reportProvider,
                  region: region,
                  isHindi: isHindi,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTapChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String type,
    required ReportProvider reportProvider,
    required dynamic region,
    required bool isHindi,
  }) {
    return InkWell(
      onTap: reportProvider.isSubmitting
          ? null
          : () async {
              final ok = await reportProvider.submitQuickReport(
                reportType: type,
                lat: region.latitude,
                lon: region.longitude,
                villageName: region.name,
                isHindi: isHindi,
              );
              if (context.mounted && ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isHindi
                          ? "$label दर्ज किया गया (ID: ASHA-PB-104)!"
                          : "$label reported (ID: ASHA-PB-104)!",
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: AppColors.primaryDark,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
