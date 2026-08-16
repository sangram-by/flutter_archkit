import '../../../core/network/mock_api_client.dart';
import '../models/task_model.dart';

/// MVVM Architecture - Service Layer
/// Handles data access, web API requests, or local storage.
class TaskService {
  final MockApiClient apiClient;

  TaskService({required this.apiClient});

  Future<List<TaskModel>> fetchTasks() async {
    final response = await apiClient.get('/api/v1/tasks');
    if (response.isSuccess && response.data != null) {
      final List rawList = response.data!['tasks'] as List;
      return rawList.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
