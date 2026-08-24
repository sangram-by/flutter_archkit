import 'package:flutter/material.dart';
import '../../../../core/network/mock_api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../widgets/code_preview_dialog.dart';
import '../../../../widgets/folder_tree_view.dart';
import '../controllers/analytics_controller.dart';

class MvcArchitecturePage extends StatefulWidget {
  const MvcArchitecturePage({super.key});

  @override
  State<MvcArchitecturePage> createState() => _MvcArchitecturePageState();
}

class _MvcArchitecturePageState extends State<MvcArchitecturePage> {
  late final AnalyticsController _controller;

  @override
  void initState() {
    super.initState();
    final apiClient = MockApiClient();
    _controller = AnalyticsController(apiClient: apiClient);
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.fetchAnalytics();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = _controller.model;

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
                  AppTheme.accentGreen.withValues(alpha: 0.2),
                  AppTheme.accentBlue.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppTheme.accentGreen,
                  radius: 24,
                  child: Icon(Icons.dashboard_customize_rounded, color: AppTheme.darkBackground),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'MVC Architecture Pattern',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Model-View-Controller structure. Controllers process input events, mutate Model, and update View.',
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
            title: 'Scaffolded MVC Structure (lib/)',
            nodes: [
              FileTreeNode(name: 'models/', isDirectory: true, description: 'AnalyticsModel, State data structures'),
              FileTreeNode(name: 'controllers/', isDirectory: true, description: 'AnalyticsController, Input handling & business logic'),
              FileTreeNode(name: 'views/', isDirectory: true, description: 'AnalyticsView, UI widgets'),
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
                        'Interactive Demo: Controller Analytics Dashboard',
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
                            'MVC Controller Handling',
                            '''
class AnalyticsController extends ChangeNotifier {
  AnalyticsModel _model = AnalyticsModel.initial();

  void simulateTrafficSpike() {
    // Controller mutates model directly
    _model = AnalyticsModel(activeUsers: _model.activeUsers + 250...);
    notifyListeners();
  }
}
''',
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_controller.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Row(
                      children: [
                        _buildMetricTile(
                          'Active Users',
                          model.activeUsers.toString(),
                          Icons.people_alt_outlined,
                          AppTheme.accentBlue,
                        ),
                        const SizedBox(width: 12),
                        _buildMetricTile(
                          'Requests / sec',
                          model.requestsPerSec.toString(),
                          Icons.speed,
                          AppTheme.accentOrange,
                        ),
                        const SizedBox(width: 12),
                        _buildMetricTile(
                          'System Uptime',
                          model.uptime,
                          Icons.verified_outlined,
                          AppTheme.accentGreen,
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _controller.simulateTrafficSpike(),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGreen),
                        icon: const Icon(Icons.bolt),
                        label: const Text('Controller: Simulate Traffic Spike'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => _controller.fetchAnalytics(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Data'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF020617),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
