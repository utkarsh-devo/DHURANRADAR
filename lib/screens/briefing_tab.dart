import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/briefing_provider.dart';
import '../widgets/risk_card.dart';
import '../widgets/exposure_area_card.dart';
import '../widgets/weather_wind_card.dart';
import '../widgets/official_advisory_card.dart';
import '../widgets/ground_check_bar.dart';
import '../widgets/downwind_relay_card.dart';
import '../constants/app_colors.dart';

class BriefingTab extends StatelessWidget {
  const BriefingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BriefingProvider>();
    final isHindi = provider.isHindi;
    final briefing = provider.briefing;

    return RefreshIndicator(
      onRefresh: () => provider.loadBriefing(),
      color: AppColors.primaryDark,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Region Selector Dropdown Bar
          _buildRegionSelector(context, provider),
          const SizedBox(height: 14),

          // Loading state
          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryDark),
                    SizedBox(height: 16),
                    Text(
                      "Fetching satellite fire data & weather forecast...",
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          // Error state / Backend Offline
          else if (provider.errorMessage != null && briefing == null)
            _buildBackendOfflineBanner(context, provider)
          // Briefing Content
          else if (briefing != null) ...[
            // 1. Downwind Relay Alert (if any active upwind report exists)
            if (briefing.relayAlert != null)
              DownwindRelayCard(relayAlert: briefing.relayAlert!, isHindi: isHindi),

            // 2. Main Risk & Confidence Card
            RiskCard(briefing: briefing, isHindi: isHindi),
            const SizedBox(height: 14),

            // 3. Potential Exposure Area (Radar / Hotspots)
            ExposureAreaCard(briefing: briefing, isHindi: isHindi),
            const SizedBox(height: 14),

            // 4. Weather & Wind Card (Open-Meteo)
            WeatherWindCard(weather: briefing.weather, isHindi: isHindi),
            const SizedBox(height: 14),

            // 5. Official Advisory Card (TinyFish)
            OfficialAdvisoryCard(advisory: briefing.officialAdvisory, isHindi: isHindi),
            const SizedBox(height: 16),

            // 6. Log Ground Check Bar (Slide 7)
            const GroundCheckBar(),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildRegionSelector(BuildContext context, BriefingProvider provider) {
    final isHindi = provider.isHindi;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, size: 18, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<RegionPreset>(
                value: provider.selectedRegion,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                onChanged: (preset) {
                  if (preset != null) {
                    provider.selectRegion(preset);
                  }
                },
                items: provider.presets.map((p) {
                  return DropdownMenuItem<RegionPreset>(
                    value: p,
                    child: Text(
                      isHindi ? p.nameHi : p.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackendOfflineBanner(BuildContext context, BriefingProvider provider) {
    final isHindi = provider.isHindi;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_off, color: AppColors.riskHigh, size: 24),
              const SizedBox(width: 10),
              Text(
                isHindi ? "बैकएंड कनेक्ट नहीं हो सका" : "Unable to Connect to Backend",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.riskHigh,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isHindi
                ? "कृपया सुनिश्चित करें कि FastAPI बैकएंड चल रहा है:\nuvicorn app.main:app --reload --host 0.0.0.0 --port 8000"
                : "Please ensure your FastAPI backend is running on port 8000:\n\nuvicorn app.main:app --reload --host 0.0.0.0 --port 8000",
            style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B), height: 1.4),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => provider.loadBriefing(),
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(isHindi ? "पुनः प्रयास करें (Retry)" : "Retry Connection"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
