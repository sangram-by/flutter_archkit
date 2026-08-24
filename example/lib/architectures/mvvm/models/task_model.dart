/// MVVM Architecture - Model Layer
/// Stores data state and task item structure.
class TaskModel {
  final String id;
  final String title;
  final bool completed;

  const TaskModel({
    required this.id,
    required this.title,
    this.completed = false,
  });

  TaskModel copyWith({String? id, String? title, bool? completed}) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      completed: json['completed'] ?? false,
    );
  }
}
