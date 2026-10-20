import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/briefing_model.dart';
import '../models/report_model.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches evening smoke briefing for coordinates
  Future<BriefingModel> getBriefing({
    required double lat,
    required double lon,
    String? villageName,
    double radiusKm = 50.0,
  }) async {
    final queryParams = {
      'lat': lat.toString(),
      'lon': lon.toString(),
      if (villageName != null && villageName.isNotEmpty) 'village_name': villageName,
      'radius_km': radiusKm.toString(),
    };

    final uri = Uri.parse(ApiConstants.briefingEndpoint).replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return BriefingModel.fromJson(decoded);
      } else {
        throw Exception('Server returned error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to DhuanRadar backend ($uri): $e');
    }
  }

  /// Submits an ASHA/ANM field report (e.g. "Fire nearby", "Heavy smoke")
  Future<FieldReport> submitReport({
    required String workerId,
    String workerRole = 'ASHA',
    String villageName = 'Sample Village',
    required double lat,
    required double lon,
    required String reportType,
    String? notes,
  }) async {
    final uri = Uri.parse(ApiConstants.reportsEndpoint);
    final payload = {
      'worker_id': workerId,
      'worker_role': workerRole,
      'village_name': villageName,
      'latitude': lat,
      'longitude': lon,
      'report_type': reportType,
      'notes': notes,
    };

    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return FieldReport.fromJson(decoded);
      } else {
        throw Exception('Failed to submit report (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error submitting field report: $e');
    }
  }

  /// Retrieves recent ground check reports
  Future<List<FieldReport>> getRecentReports({
    double? lat,
    double? lon,
    double radiusKm = 50.0,
  }) async {
    final queryParams = <String, String>{
      'radius_km': radiusKm.toString(),
      if (lat != null) 'lat': lat.toString(),
      if (lon != null) 'lon': lon.toString(),
    };

    final uri = Uri.parse(ApiConstants.reportsEndpoint).replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        return decoded.map((e) => FieldReport.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        return [];
      }
    } catch (_) {
      return [];
    }
  }

  /// Checks if downwind relay is active for target location
  Future<DownwindRelayAlert> checkRelay({
    required double lat,
    required double lon,
  }) async {
    final uri = Uri.parse(ApiConstants.relayEndpoint).replace(
      queryParameters: {'lat': lat.toString(), 'lon': lon.toString()},
    );

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return DownwindRelayAlert.fromJson(decoded);
      }
    } catch (_) {}

    return DownwindRelayAlert(
      active: false,
      message: 'Relay service unavailable or offline.',
      messageHi: 'रिले सेवा अनुपलब्ध या ऑफ़लाइन है।',
      statusLabel: 'Unverified',
      warningNote: 'Always "Unverified" (a heads up, not an alarm).',
    );
  }

  /// Backend operational health check
  Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse(ApiConstants.healthEndpoint);
      final resp = await _client.get(uri).timeout(const Duration(seconds: 3));
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
