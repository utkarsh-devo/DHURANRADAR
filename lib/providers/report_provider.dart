import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/report_model.dart';

class ReportProvider extends ChangeNotifier {
  final ApiService _apiService;

  ReportProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  List<FieldReport> _reports = [];
  List<FieldReport> get reports => _reports;

  DownwindRelayAlert? _relayAlert;
  DownwindRelayAlert? get relayAlert => _relayAlert;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool _isLoadingReports = false;
  bool get isLoadingReports => _isLoadingReports;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  Future<bool> submitQuickReport({
    required String reportType,
    required double lat,
    required double lon,
    required String villageName,
    String? notes,
    required bool isHindi,
  }) async {
    _isSubmitting = true;
    _statusMessage = null;
    notifyListeners();

    try {
      final report = await _apiService.submitReport(
        workerId: 'ASHA-PB-104',
        workerRole: 'ASHA',
        villageName: villageName,
        lat: lat,
        lon: lon,
        reportType: reportType,
        notes: notes,
      );

      _reports.insert(0, report);
      _statusMessage = isHindi
          ? "ग्राउंड चेक सफलतापूर्वक दर्ज किया गया!"
          : "Ground check successfully recorded!";
      _isSubmitting = false;
      notifyListeners();

      // Check downwind relay immediately after submitting
      await checkRelay(lat: lat, lon: lon);
      return true;
    } catch (e) {
      _statusMessage = "Error: $e";
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchReports({double? lat, double? lon}) async {
    _isLoadingReports = true;
    notifyListeners();

    try {
      _reports = await _apiService.getRecentReports(lat: lat, lon: lon);
    } catch (_) {}

    _isLoadingReports = false;
    notifyListeners();
  }

  Future<void> checkRelay({required double lat, required double lon}) async {
    try {
      _relayAlert = await _apiService.checkRelay(lat: lat, lon: lon);
      notifyListeners();
    } catch (_) {}
  }
}
