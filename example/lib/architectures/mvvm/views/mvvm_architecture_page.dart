import 'package:flutter/material.dart';
import '../../../../core/network/mock_api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../widgets/code_preview_dialog.dart';
import '../../../../widgets/folder_tree_view.dart';
import '../services/task_service.dart';
import '../viewmodels/task_viewmodel.dart';

class MvvmArchitecturePage extends StatefulWidget {
  const MvvmArchitecturePage({super.key});

  @override
  State<MvvmArchitecturePage> createState() => _MvvmArchitecturePageState();
}

class _MvvmArchitecturePageState extends State<MvvmArchitecturePage> {
  late final TaskViewModel _viewModel;
  final TextEditingController _taskInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final apiClient = MockApiClient();
    final taskService = TaskService(apiClient: apiClient);
    _viewModel = TaskViewModel(taskService: taskService);
    _viewModel.addListener(() {
      if (mounted) setState(() {});
    });
    _viewModel.fetchTasks();
  }

  @override
  void dispose() {
    _taskInputController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentPurple.withValues(alpha: 0.2),
                  AppTheme.accentOrange.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppTheme.accentPurple,
                  radius: 24,
                  child: Icon(Icons.view_compact_alt_rounded, color: AppTheme.darkBackground),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'MVVM Architecture Pattern',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Model-View-ViewModel with Data Binding. Decouples UI rendering from business services.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Folder Tree Section
          const FolderTreeView(
            title: 'Scaffolded MVVM Structure (lib/)',
            nodes: [
              FileTreeNode(name: 'models/', isDirectory: true, description: 'TaskModel, Data structures'),
              FileTreeNode(name: 'services/', isDirectory: true, description: 'TaskService, Network/Database access'),
              FileTreeNode(name: 'viewmodels/', isDirectory: true, description: 'TaskViewModel, Reactive State & Binding'),
              FileTreeNode(name: 'views/', isDirectory: true, description: 'TaskView, Flutter UI Widgets'),
            ],
          ),
          const SizedBox(height: 20),

          // Interactive Execution Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Interactive Demo: Reactive Task ViewModel',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.code, size: 16),
                        label: const Text('View Snippet'),
                        onPressed: () {
                          CodePreviewDialog.show(
                            context,
                            'MVVM ViewModel Structure',
                            '''
class TaskViewModel extends ChangeNotifier {
  final TaskService taskService;
  List<TaskModel> _tasks = [];

  void toggleTask(String id) {
    // Modify task model state
    notifyListeners(); // View automatically updates
  }
}
''',
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Add Task Row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _taskInputController,
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Add new task...',
                            hintStyle: const TextStyle(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          _viewModel.addTask(_taskInputController.text);
                          _taskInputController.clear();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentPurple),
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_viewModel.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column(
                      children: _viewModel.tasks.map((task) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF020617),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF1E293B)),
                          ),
                          child: CheckboxListTile(
                            title: Text(
                              task.title,
                              style: TextStyle(
                                color: task.completed
                                    ? AppTheme.textSecondary
                                    : AppTheme.textPrimary,
                                decoration: task.completed
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                fontSize: 14,
                              ),
                            ),
                            value: task.completed,
                            activeColor: AppTheme.accentPurple,
                            onChanged: (_) => _viewModel.toggleTask(task.id),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
