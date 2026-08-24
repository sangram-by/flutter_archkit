import 'package:flutter/material.dart';
import '../../../core/network/mock_api_client.dart';
import '../models/analytics_model.dart';

/// MVC Architecture - Controller Layer
/// Receives UI events from View, updates Model state, and notifies View to re-render.
class AnalyticsController extends ChangeNotifier {
  final MockApiClient apiClient;

  AnalyticsController({required this.apiClient});

  AnalyticsModel _model = AnalyticsModel.initial();
  AnalyticsModel get model => _model;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchAnalytics() async {
    _isLoading = true;
    notifyListeners();

    final response = await apiClient.get('/api/v1/analytics');
    if (response.isSuccess && response.data != null) {
      _model = AnalyticsModel.fromJson(response.data!);
    }

    _isLoading = false;
    notifyListeners();
  }

  void simulateTrafficSpike() {
    _model = AnalyticsModel(
      activeUsers: _model.activeUsers + 250,
      requestsPerSec: _model.requestsPerSec + 120,
      uptime: _model.uptime,
    );
    notifyListeners();
  }
}
