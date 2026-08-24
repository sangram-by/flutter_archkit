import 'package:flutter/material.dart';
import 'architectures/clean/presentation/pages/clean_architecture_page.dart';
import 'architectures/mvc/views/mvc_architecture_page.dart';
import 'architectures/mvvm/views/mvvm_architecture_page.dart';
import 'core/config/server_config.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ArchKitExampleApp());
}

class ArchKitExampleApp extends StatelessWidget {
  const ArchKitExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ArchKit Showcase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const ArchKitShowcaseScreen(),
    );
  }
}

class ArchKitShowcaseScreen extends StatefulWidget {
  const ArchKitShowcaseScreen({super.key});

  @override
  State<ArchKitShowcaseScreen> createState() => _ArchKitShowcaseScreenState();
}

class _ArchKitShowcaseScreenState extends State<ArchKitShowcaseScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final ServerConfig _serverConfig = ServerConfig.dev;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.layers_outlined, color: AppTheme.accentBlue),
            SizedBox(width: 8),
            Text('Flutter ArchKit Architecture Showcase'),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              // Flavor & Environment Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                color: const Color(0xFF1E293B),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.tune, size: 14, color: AppTheme.accentGreen),
                    const SizedBox(width: 6),
                    Text(
                      'Flavor: ${_serverConfig.environment.toUpperCase()} | Base URL: ${_serverConfig.baseUrl}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.accentBlue,
                indicatorWeight: 3,
                labelColor: AppTheme.accentBlue,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.architecture, size: 20),
                    text: 'Clean Architecture',
                  ),
                  Tab(
                    icon: Icon(Icons.view_compact_alt_rounded, size: 20),
                    text: 'MVVM Architecture',
                  ),
                  Tab(
                    icon: Icon(Icons.dashboard_customize_rounded, size: 20),
                    text: 'MVC Architecture',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CleanArchitecturePage(),
          MvvmArchitecturePage(),
          MvcArchitecturePage(),
        ],
      ),
    );
  }
}
