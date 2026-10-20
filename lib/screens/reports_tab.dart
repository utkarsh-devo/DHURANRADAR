import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/report_provider.dart';
import '../providers/briefing_provider.dart';
import '../models/report_model.dart';
import '../constants/app_colors.dart';

class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  final TextEditingController _notesController = TextEditingController();
  String _selectedType = 'SMOKE_SEEN';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final briefingProvider = context.read<BriefingProvider>();
      final reportProvider = context.read<ReportProvider>();
      reportProvider.fetchReports(
        lat: briefingProvider.selectedRegion.latitude,
        lon: briefingProvider.selectedRegion.longitude,
      );
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Color _getReportTypeColor(String type) {
    switch (type) {
      case 'FIRE_NEARBY':
        return AppColors.riskHigh;
      case 'HEAVY_SMOKE':
        return AppColors.riskModerate;
      case 'SMOKE_SEEN':
        return const Color(0xFF0284C7);
      default:
        return AppColors.riskLow;
    }
  }

  IconData _getReportIcon(String type) {
    switch (type) {
      case 'FIRE_NEARBY':
        return Icons.local_fire_department;
      case 'HEAVY_SMOKE':
        return Icons.grain;
      case 'SMOKE_SEEN':
        return Icons.cloud_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();
    final briefingProvider = context.watch<BriefingProvider>();
    final isHindi = briefingProvider.isHindi;
    final region = briefingProvider.selectedRegion;

    return RefreshIndicator(
      onRefresh: () => reportProvider.fetchReports(lat: region.latitude, lon: region.longitude),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.fact_check_outlined, color: AppColors.primaryBlue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isHindi ? "फील्ड रिपोर्ट और डाउनविंड रिले" : "Field Reports & Downwind Relay",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isHindi
                      ? "स्लाइड 7: एक पंजीकृत आशा कार्यकर्ता की 'पास में आग' या 'घना धुआं' रिपोर्ट हवा के रुख के अनुसार डाउनविंड गांवों को अपुष्ट अलर्ट के रूप में भेजी जाती है।"
                      : "Slide 7: A registered ASHA worker's 'Fire nearby' or 'Heavy smoke' report goes, marked Unverified, to health workers of downwind areas if wind data confirms it.",
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Custom Report Submission Form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi ? "नया फील्ड अवलोकन दर्ज करें" : "Submit Field Observation",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 10),

                // Report type selector
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: InputDecoration(
                    labelText: isHindi ? "अवलोकन का प्रकार" : "Observation Type",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'FIRE_NEARBY',
                      child: Text(isHindi ? "🔥 पास में आग (Fire nearby)" : "🔥 Fire nearby"),
                    ),
                    DropdownMenuItem(
                      value: 'HEAVY_SMOKE',
                      child: Text(isHindi ? "💨 घना धुआं (Heavy smoke)" : "💨 Heavy smoke"),
                    ),
                    DropdownMenuItem(
                      value: 'SMOKE_SEEN',
                      child: Text(isHindi ? "🌫️ धुआं दिख रहा है (Smoke seen)" : "🌫️ Smoke seen"),
                    ),
                    DropdownMenuItem(
                      value: 'NO_SMOKE',
                      child: Text(isHindi ? "✅ धुआं नहीं है (No smoke)" : "✅ No smoke"),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 12),

                // Notes textfield
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: isHindi ? "अतिरिक्त विवरण / नोट्स (वैकल्पिक)" : "Field notes (optional)",
                    hintText: isHindi ? "जैसे: पश्चिमी खेत में पराली की आग..." : "e.g. Stubble fire along western road...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 14),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: reportProvider.isSubmitting
                        ? null
                        : () async {
                            final success = await reportProvider.submitQuickReport(
                              reportType: _selectedType,
                              lat: region.latitude,
                              lon: region.longitude,
                              villageName: region.name,
                              notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                              isHindi: isHindi,
                            );
                            if (success) {
                              _notesController.clear();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isHindi ? "अवलोकन सफलतापूर्वक दर्ज किया गया!" : "Observation successfully logged!",
                                    ),
                                    backgroundColor: AppColors.primaryDark,
                                  ),
                                );
                              }
                            }
                          },
                    icon: reportProvider.isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send, size: 16),
                    label: Text(
                      isHindi ? "जमीनी रिपोर्ट सबमिट करें" : "Submit Ground Report",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Recent Reports List
          Text(
            isHindi ? "हालिया जमीनी रिपोर्टें" : "Recent Ground Reports",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),

          if (reportProvider.isLoadingReports)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          else if (reportProvider.reports.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Center(
                child: Text(
                  isHindi ? "कोई रिपोर्ट दर्ज नहीं की गई है।" : "No field reports recorded yet.",
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else
            ...reportProvider.reports.map((report) => _buildReportTile(report, isHindi)),
        ],
      ),
    );
  }

  Widget _buildReportTile(FieldReport report, bool isHindi) {
    final color = _getReportTypeColor(report.reportType);
    final icon = _getReportIcon(report.reportType);
    final timeStr = DateFormat('dd MMM, hh:mm a').format(report.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isHindi ? report.reportLabelHi : report.reportLabelEn,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      timeStr,
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  "${report.villageName ?? 'Cluster'} · ${report.workerRole} (${report.workerId})",
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                if (report.notes != null && report.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    '"${report.notes!}"',
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF334155)),
                  ),
                ],
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    report.verificationStatus,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
