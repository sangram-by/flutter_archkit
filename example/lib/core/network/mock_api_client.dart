import 'dart:async';

/// Generic ApiResponse wrapper as scaffolded by `archkit network`
class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool isSuccess;

  const ApiResponse.success(this.data, {this.message}) : isSuccess = true;
  const ApiResponse.error(this.message)
      : data = null,
        isSuccess = false;
}

/// Simulated Remote API Client
class MockApiClient {
  Future<ApiResponse<Map<String, dynamic>>> get(String endpoint) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (endpoint.contains('user')) {
      return const ApiResponse.success({
        'id': 'usr_101',
        'name': 'Alex Rivers',
        'email': 'alex.rivers@archkit.dev',
        'role': 'Lead Architect',
        'avatar': 'https://i.pravatar.cc/150?u=alex',
      });
    } else if (endpoint.contains('tasks')) {
      return const ApiResponse.success({
        'tasks': [
          {'id': '1', 'title': 'Implement Clean Architecture', 'completed': true},
          {'id': '2', 'title': 'Configure Multi-Flavor setup', 'completed': true},
          {'id': '3', 'title': 'Setup MVVM & MVC Demo Screens', 'completed': false},
        ]
      });
    } else if (endpoint.contains('analytics')) {
      return const ApiResponse.success({
        'activeUsers': 1420,
        'requestsPerSec': 350,
        'uptime': '99.98%',
      });
    }
    return const ApiResponse.error('Endpoint not found');
  }
}
