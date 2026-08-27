import 'dart:io';

import 'android/android_flavor_generator.dart';
import 'config/server_config_generator.dart';
import 'ide/intellij_run_config_generator.dart';
import 'ide/vscode_launch_generator.dart';
import 'ios/ios_flavor_generator.dart';
import 'parser/flavor_config.dart';

/// Handles writing/updating flavor-related files in the consuming app:
/// - `android/app/build.gradle.kts`
/// - `ios/Runner/Info.plist`
/// - `lib/core/config/server_config.dart` configuration
/// - `.vscode/launch.json` configurations
/// - `.run/<flavor>.run.xml` configurations
class FlavorGenerator {
  final List<FlavorConfig> flavors;
  final String projectRoot;

  FlavorGenerator({required this.flavors, this.projectRoot = '.'});

  Future<void> run() async {
    // 1. Generate Android configurations
    final androidGen = AndroidFlavorGenerator(
      flavors: flavors,
      projectRoot: projectRoot,
    );
    await androidGen.run();

    // 2. Generate iOS configurations
    final iosGen = IosFlavorGenerator(
      flavors: flavors,
      projectRoot: projectRoot,
    );
    await iosGen.run();

    // 3. Generate ServerConfig (lib/core/config/server_config.dart)
    final serverConfigGen = ServerConfigGenerator(
      flavors: flavors,
      projectRoot: projectRoot,
    );
    await serverConfigGen.run();

    // 4. Update Dart main entry point
    await _updateMainEntryPoint();

    // 5. Generate VS Code launch configurations
    final vscodeGen = VscodeLaunchGenerator(
      flavors: flavors,
      projectRoot: projectRoot,
    );
    await vscodeGen.run();

    // 6. Generate IntelliJ / Android Studio run configurations
    final intellijGen = IntellijRunConfigGenerator(
      flavors: flavors,
      projectRoot: projectRoot,
    );
    await intellijGen.run();

    stdout.writeln(
      '✅ Flavor setup complete for: ${flavors.map((f) => f.name).join(', ')}',
    );
  }

  // ---------------------------------------------------------------------
  // lib/main.dart entry point update
  // ---------------------------------------------------------------------
  Future<void> _updateMainEntryPoint() async {
    final mainFile = File('$projectRoot/lib/main.dart');
    if (!await mainFile.parent.exists()) {
      await mainFile.parent.create(recursive: true);
    }

    if (!await mainFile.exists()) {
      await mainFile.writeAsString('''
import 'package:flutter/material.dart';
import 'core/config/server_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final serverConfig = ServerConfig();
  await serverConfig.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(child: Text('App Initialized')),
      ),
    );
  }
}
''');
      stdout
          .writeln('✓ Created lib/main.dart with ServerConfig initialization');
      return;
    }

    var content = await mainFile.readAsString();

    if (content.contains('ServerConfig()') &&
        content.contains('serverConfig.init()')) {
      return;
    }

    if (!content.contains('server_config.dart')) {
      content = "import 'core/config/server_config.dart';\n$content";
    }

    const initBlock = '''
  WidgetsFlutterBinding.ensureInitialized();

  final serverConfig = ServerConfig();
  await serverConfig.init();
''';

    if (content.contains('WidgetsFlutterBinding.ensureInitialized();')) {
      content = content.replaceFirst(
        'WidgetsFlutterBinding.ensureInitialized();',
        '''WidgetsFlutterBinding.ensureInitialized();

  final serverConfig = ServerConfig();
  await serverConfig.init();''',
      );
    } else {
      final mainRegex = RegExp(
        r'(void|Future<void>)?\s*main\s*\(\s*\)\s*(async)?\s*\{',
      );
      if (mainRegex.hasMatch(content)) {
        content = content.replaceFirstMapped(mainRegex, (match) {
          return 'Future<void> main() async {\n$initBlock';
        });
      } else if (content.contains('void main() {')) {
        content = content.replaceFirst(
          'void main() {',
          'Future<void> main() async {\n$initBlock',
        );
      }
    }

    content = content.replaceFirst(
      'void main() async {',
      'Future<void> main() async {',
    );

    await mainFile.writeAsString(content);
    stdout.writeln(
      '✓ Updated lib/main.dart with async WidgetsBinding & ServerConfig initialization',
    );
  }
}
