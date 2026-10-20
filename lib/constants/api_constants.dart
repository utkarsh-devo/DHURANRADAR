import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000';
      }
    } catch (_) {}
    return 'http://localhost:8000';
  }

  // Active base URL (user can configure in settings)
  static String activeBaseUrl = defaultBaseUrl;

  static String get briefingEndpoint => '$activeBaseUrl/briefing';
  static String get apiV1Briefing => '$activeBaseUrl/api/v1/briefing';
  static String get reportsEndpoint => '$activeBaseUrl/api/v1/reports';
  static String get relayEndpoint => '$activeBaseUrl/api/v1/relay';
  static String get advisoryEndpoint => '$activeBaseUrl/api/v1/advisory';
  static String get healthEndpoint => '$activeBaseUrl/api/v1/health';
}
