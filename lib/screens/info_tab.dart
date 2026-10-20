import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/briefing_provider.dart';
import '../constants/api_constants.dart';
import '../constants/app_colors.dart';

class InfoTab extends StatefulWidget {
  const InfoTab({super.key});

  @override
  State<InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urlController.text = ApiConstants.activeBaseUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final briefingProvider = context.watch<BriefingProvider>();
    final isHindi = briefingProvider.isHindi;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // App & Team Overview
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.radar, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "DhuanRadar",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      Text(
                        "From Fire Detection to Local Smoke Awareness",
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),
              const Text(
                "Team ByteForge:",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 4),
              const Text(
                "1. Nidhish Gupta\n2. Bitthal Bhai Vinayak\n3. Utkarsh Trivedi",
                style: TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.4),
              ),
              const SizedBox(height: 10),
              Text(
                isHindi
                    ? "लक्ष्य: ग्रामीण स्वास्थ्य कार्यकर्ताओं (आशा/एएनएम) को समय पर पारदर्शी शाम की धुआं ब्रीफिंग प्रदान करना।"
                    : "Target: Providing rural health workers (ASHA/ANM) with same-day, village-level smoke awareness with stated confidence.",
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.35),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Rules Engine Transparency (Slide 4 & 5)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.balance, color: AppColors.primaryBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isHindi ? "पारदर्शी नियम, ब्लैक बॉक्स नहीं" : "Transparent Rules, Not a Black Box",
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isHindi
                    ? "डेक स्लाइड 4 और 5 के आधार पर, यह प्रणाली किसी ब्लैक बॉक्स एआई पर निर्भर नहीं करती, बल्कि स्पष्ट नियमों पर आधारित है:"
                    : "As per slides 4 & 5, DhuanRadar does not use a black box. Scoring is fully explainable:",
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.35),
              ),
              const SizedBox(height: 12),

              _buildDeckExampleCard(
                title: "Example A: Some Fire Activity",
                points: "2 Points (MODERATE 2-3)",
                details: "2 nearby hotspots (+2) · Wind uncertain (0)\nConfidence: LOW (2 data gaps: wind uncertain, weather incomplete)",
                badgeColor: AppColors.riskModerate,
              ),
              const SizedBox(height: 10),
              _buildDeckExampleCard(
                title: "Example B: Stale / Missing Data",
                points: "N/A Points (UNKNOWN)",
                details: "No recent valid hotspot data · Wind unknown\nConfidence: LOW (Insufficient data. No alert ≠ no smoke)",
                badgeColor: AppColors.riskUnknown,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Backend Connection Settings
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.dns_outlined, color: AppColors.accentTeal, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isHindi ? "फास्टएपीआई बैकएंड सेटिंग्स" : "FastAPI Backend Settings",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isHindi
                    ? "एंड्रॉइड एमुलेटर: http://10.0.2.2:8000\nवेब या विंडोज: http://localhost:8000"
                    : "Android Emulator: http://10.0.2.2:8000\nWeb / Windows Desktop: http://localhost:8000",
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: "Base URL",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  briefingProvider.updateBackendUrl(_urlController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Backend URL updated!")),
                  );
                },
                icon: const Icon(Icons.save, size: 16),
                label: Text(isHindi ? "सेटिंग सहेजें (Save)" : "Save & Reconnect"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeckExampleCard({
    required String title,
    required String points,
    required String details,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  points,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(details, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.35)),
        ],
      ),
    );
  }
}
