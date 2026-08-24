import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

/// MVVM Architecture - ViewModel Layer
/// Prepares presentation logic, handles UI commands, and binds state to View via ChangeNotifier.
class TaskViewModel extends ChangeNotifier {
  final TaskService taskService;

  TaskViewModel({required this.taskService});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<TaskModel> _tasks = [];
  List<TaskModel> get tasks => List.unmodifiable(_tasks);

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();

    _tasks = await taskService.fetchTasks();

    _isLoading = false;
    notifyListeners();
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final current = _tasks[index];
      _tasks[index] = current.copyWith(completed: !current.completed);
      notifyListeners();
    }
  }

  void addTask(String title) {
    if (title.trim().isEmpty) return;
    final newTask = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      completed: false,
    );
    _tasks = [..._tasks, newTask];
    notifyListeners();
  }
}
