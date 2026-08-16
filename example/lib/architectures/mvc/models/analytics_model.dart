/// MVC Architecture - Model Layer
/// Represents state data and domain logic for the controller and view.
class AnalyticsModel {
  final int activeUsers;
  final int requestsPerSec;
  final String uptime;

  const AnalyticsModel({
    required this.activeUsers,
    required this.requestsPerSec,
    required this.uptime,
  });

  factory AnalyticsModel.initial() {
    return const AnalyticsModel(
      activeUsers: 0,
      requestsPerSec: 0,
      uptime: '0%',
    );
  }

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      activeUsers: json['activeUsers'] ?? 0,
      requestsPerSec: json['requestsPerSec'] ?? 0,
      uptime: json['uptime'] ?? '99.9%',
    );
  }
}
