import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../widgets/code_preview_dialog.dart';
import '../../../../widgets/folder_tree_view.dart';
import '../../di/clean_user_di.dart';
import '../state/clean_user_notifier.dart';

class CleanArchitecturePage extends StatefulWidget {
  const CleanArchitecturePage({super.key});

  @override
  State<CleanArchitecturePage> createState() => _CleanArchitecturePageState();
}

class _CleanArchitecturePageState extends State<CleanArchitecturePage> {
  late final CleanUserNotifier _notifier;

  @override
  void initState() {
    super.initState();
    final useCase = CleanUserDI.provideFetchUserProfileUseCase();
    _notifier = CleanUserNotifier(fetchUserProfileUseCase: useCase);
    _notifier.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _notifier.dispose();
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
                  AppTheme.accentBlue.withValues(alpha: 0.2),
                  AppTheme.accentPurple.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppTheme.accentBlue,
                  radius: 24,
                  child: Icon(Icons.architecture, color: AppTheme.darkBackground),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Clean Architecture Pattern',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Strict layer separation into Data, Domain, Presentation, and DI. Highly testable & decoupled.',
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
            title: 'Scaffolded Feature Structure (lib/features/user/)',
            nodes: [
              FileTreeNode(
                name: 'data',
                isDirectory: true,
                description: 'API, DB, repositories implementation & models',
                children: [
                  FileTreeNode(name: 'data_sources/', isDirectory: true),
                  FileTreeNode(name: 'models/', isDirectory: true),
                  FileTreeNode(name: 'repositories/', isDirectory: true),
                ],
              ),
              FileTreeNode(
                name: 'domain',
                isDirectory: true,
                description: 'Pure Dart business logic (Entities, Usecases, Contracts)',
                children: [
                  FileTreeNode(name: 'entities/', isDirectory: true),
                  FileTreeNode(name: 'repositories/', isDirectory: true),
                  FileTreeNode(name: 'usecases/', isDirectory: true),
                ],
              ),
              FileTreeNode(
                name: 'presentation',
                isDirectory: true,
                description: 'UI Views & State Management (Bloc / Cubit / Riverpod / Notifier)',
                children: [
                  FileTreeNode(name: 'pages/', isDirectory: true),
                  FileTreeNode(name: 'state/', isDirectory: true),
                ],
              ),
              FileTreeNode(
                name: 'di',
                isDirectory: true,
                description: 'Dependency Injection wiring (GetIt / Injectable)',
              ),
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
                        'Interactive Demo: User Profile Usecase',
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
                            'Clean Architecture Usecase Call',
                            '''
// Domain Layer Usecase
class FetchUserProfileUseCase {
  final UserRepository repository;
  FetchUserProfileUseCase({required this.repository});

  Future<UserEntity> call(String userId) async {
    return await repository.getUserProfile(userId);
  }
}

// Presentation Notifier
final user = await fetchUserProfileUseCase('usr_101');
''',
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildContentArea(),

                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _notifier.state == CleanUserState.loading
                        ? null
                        : () => _notifier.loadUserProfile('usr_101'),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      _notifier.state == CleanUserState.loading
                          ? 'Executing Usecase...'
                          : 'Trigger Usecase Data Flow',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    switch (_notifier.state) {
      case CleanUserState.initial:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.accentBlue),
              SizedBox(width: 12),
              Text(
                'Click button to trigger Domain Usecase -> Repository -> Data Source',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
        );
      case CleanUserState.loading:
        return Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.center,
          child: const Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Passing request through Domain & Data layers...',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            ],
          ),
        );
      case CleanUserState.loaded:
        final user = _notifier.user!;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF020617),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.accentGreen.withValues(alpha: 0.2),
                radius: 26,
                child: Text(
                  user.name.substring(0, 1),
                  style: const TextStyle(
                      color: AppTheme.accentGreen, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(user.email,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Role: ${user.role}',
                        style: const TextStyle(
                            color: AppTheme.accentPurple,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case CleanUserState.error:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.red.shade400),
          ),
          child: Text(
            'Error: ${_notifier.errorMessage}',
            style: TextStyle(color: Colors.red.shade300, fontSize: 13),
          ),
        );
    }
  }
}
