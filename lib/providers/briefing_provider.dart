import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/briefing_model.dart';
import '../constants/api_constants.dart';

class RegionPreset {
  final String name;
  final String nameHi;
  final double latitude;
  final double longitude;

  const RegionPreset({
    required this.name,
    required this.nameHi,
    required this.latitude,
    required this.longitude,
  });
}

class BriefingProvider extends ChangeNotifier {
  final ApiService _apiService;

  BriefingProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService() {
    loadBriefing();
  }

  // Pre-configured agricultural regions in Punjab / Haryana / Delhi NCR
  final List<RegionPreset> presets = const [
    RegionPreset(
      name: "Samana Cluster (Patiala)",
      nameHi: "समाना क्लस्टर (पटियाला)",
      latitude: 30.3421,
      longitude: 76.3812,
    ),
    RegionPreset(
      name: "Ludhiana Rural",
      nameHi: "लुधियाना ग्रामीण",
      latitude: 30.9010,
      longitude: 75.8573,
    ),
    RegionPreset(
      name: "Sangrur Farm Cluster",
      nameHi: "संगरूर कृषि क्लस्टर",
      latitude: 30.1200,
      longitude: 75.5400,
    ),
    RegionPreset(
      name: "Karnal Block",
      nameHi: "करनाल ब्लॉक",
      latitude: 29.6857,
      longitude: 76.9905,
    ),
    RegionPreset(
      name: "North Delhi Outskirts",
      nameHi: "उत्तरी दिल्ली बाहरी क्षेत्र",
      latitude: 28.7041,
      longitude: 77.1025,
    ),
  ];

  late RegionPreset _selectedRegion = presets[0];
  RegionPreset get selectedRegion => _selectedRegion;

  BriefingModel? _briefing;
  BriefingModel? get briefing => _briefing;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isHindi = false;
  bool get isHindi => _isHindi;

  bool _backendOnline = true;
  bool get backendOnline => _backendOnline;

  void toggleLanguage() {
    _isHindi = !_isHindi;
    notifyListeners();
  }

  void selectRegion(RegionPreset preset) {
    _selectedRegion = preset;
    notifyListeners();
    loadBriefing();
  }

  void updateBackendUrl(String newUrl) {
    ApiConstants.activeBaseUrl = newUrl.trim();
    notifyListeners();
    loadBriefing();
  }

  Future<void> loadBriefing() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _briefing = await _apiService.getBriefing(
        lat: _selectedRegion.latitude,
        lon: _selectedRegion.longitude,
        villageName: _isHindi ? _selectedRegion.nameHi : _selectedRegion.name,
      );
      _backendOnline = true;
    } catch (e) {
      _errorMessage = e.toString();
      _backendOnline = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
