import 'package:flutter/material.dart';
import '../models/advisory_model.dart';
import '../constants/app_colors.dart';

class OfficialAdvisoryCard extends StatelessWidget {
  final AdvisoryModel advisory;
  final bool isHindi;

  const OfficialAdvisoryCard({
    super.key,
    required this.advisory,
    required this.isHindi,
  });

  @override
  Widget build(BuildContext context) {
    final hasVerified = advisory.isVerified;

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
                  const Icon(Icons.verified_user_outlined, size: 18, color: Color(0xFF0D9488)),
                  const SizedBox(width: 8),
                  Text(
                    isHindi ? "आधिकारिक स्वास्थ्य सलाह (TinyFish)" : "Official Advisory (TinyFish)",
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
                  color: hasVerified ? const Color(0xFFCCFBF1) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  hasVerified
                      ? (isHindi ? "सत्यापित एवं दिनांकित" : "Verified & Dated")
                      : (isHindi ? "अनुपलब्ध" : "Unavailable"),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: hasVerified ? const Color(0xFF0F766E) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title & Issued Date
          Text(
            advisory.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
          if (advisory.issuedDate != null) ...[
            const SizedBox(height: 2),
            Text(
              "${advisory.sourceName} · ${advisory.issuedDate}",
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 10),

          // Summary
          Text(
            (isHindi && advisory.summaryHi != null && advisory.summaryHi!.isNotEmpty)
                ? advisory.summaryHi!
                : advisory.summary,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF334155),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // Source link indicator & Medical Disclaimer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (advisory.sourceUrl != null)
                Text(
                  isHindi ? "स्रोत देखें →" : "View source →",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0284C7),
                  ),
                )
              else
                Text(
                  advisory.notice,
                  style: const TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),

          // Disclaimer (Deck Slide 3)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isHindi
                      ? "स्वास्थ्य मार्गदर्शन केवल आधिकारिक सलाह से आता है। DhuanRadar चिकित्सा सलाह नहीं देता है।"
                      : "Health guidance comes only from official advisories. DhuanRadar does not give medical advice.",
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
