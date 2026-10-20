import 'package:flutter/material.dart';
import '../models/report_model.dart';

class DownwindRelayCard extends StatelessWidget {
  final DownwindRelayAlert relayAlert;
  final bool isHindi;

  const DownwindRelayCard({
    super.key,
    required this.relayAlert,
    required this.isHindi,
  });

  @override
  Widget build(BuildContext context) {
    if (!relayAlert.active) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB), // Warm amber notice
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.08),
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
            children: [
              const Icon(Icons.notifications_active, size: 20, color: Color(0xFFD97706)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isHindi ? "डाउनविंड फील्ड अलर्ट (अपुष्ट)" : "Downwind Field Alert (Unverified)",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  relayAlert.statusLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            isHindi ? relayAlert.messageHi : relayAlert.message,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF78350F),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            isHindi
                ? "हमेशा 'अपुष्ट' (सिर्फ एक पूर्व-सूचना, अलार्म नहीं)।"
                : "Always 'Unverified' (a heads up, not an alarm).",
            style: const TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Color(0xFFB45309),
            ),
          ),
        ],
      ),
    );
  }
}
