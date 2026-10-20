import 'package:flutter/material.dart';
import '../models/briefing_model.dart';
import '../constants/app_colors.dart';

class RiskCard extends StatelessWidget {
  final BriefingModel briefing;
  final bool isHindi;

  const RiskCard({
    super.key,
    required this.briefing,
    required this.isHindi,
  });

  IconData _getRiskIcon(String risk) {
    switch (risk.toLowerCase()) {
      case 'high':
        return Icons.warning_amber_rounded;
      case 'moderate':
        return Icons.offline_bolt_outlined;
      case 'low':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = AppColors.getRiskColor(briefing.riskLevel);
    final riskBgColor = AppColors.getRiskBgColor(briefing.riskLevel);
    final isUnknown = briefing.riskLevel.toLowerCase() == 'unknown';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isHindi ? "ग्राम स्वास्थ्य टीमों के लिए" : "For village health teams",
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  briefing.satelliteCoverageStatus == "Active"
                      ? (isHindi ? "उपग्रह: सक्रिय" : "Satellite: Active")
                      : (isHindi ? "विंडो समाप्त" : "Window Expired"),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status Badges (Risk & Confidence)
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              // Risk Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: riskBgColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: riskColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getRiskIcon(briefing.riskLevel), size: 18, color: riskColor),
                    const SizedBox(width: 8),
                    Text(
                      isHindi
                          ? "जोखिम: ${briefing.riskLevelHi}"
                          : "Risk: ${briefing.riskLevel}",
                      style: TextStyle(
                        color: riskColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Confidence Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Color(0xFF475569)),
                    const SizedBox(width: 6),
                    Text(
                      isHindi
                          ? "विश्वसनीयता: ${briefing.confidenceHi}"
                          : "Confidence: ${briefing.confidence}",
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Reason Section
          Text(
            isHindi ? "कारण (Reason):" : "Reason:",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isHindi ? briefing.reasonHi : briefing.reason,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),

          // Next Step for Health Worker (Highlight Box)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUnknown ? const Color(0xFFF8FAFC) : riskBgColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: riskColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isUnknown ? Icons.report_problem_outlined : Icons.directions_walk,
                      size: 16,
                      color: riskColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isHindi ? "स्वास्थ्य कार्यकर्ता का अगला कदम:" : "Health worker's next step:",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isHindi ? briefing.nextStepHi : briefing.nextStep,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Key Data Gaps (if any)
          if (briefing.keyDataGaps.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              isHindi ? "डेटा अंतर (Data Gaps):" : "Key Data Gaps:",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: briefing.keyDataGaps.map((gap) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    gap,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
