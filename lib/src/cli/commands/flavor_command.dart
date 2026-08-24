import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_archkit/src/flavor/flavor_generator.dart';
import 'package:flutter_archkit/src/flavor/parser/flavor_exceptions.dart';
import 'package:flutter_archkit/src/flavor/parser/flavor_yaml_loader.dart';

class FlavorCommand extends Command<int> {
  @override
  String get name => 'flavor';

  @override
  List<String> get aliases => const ['flavors', 'setup_flavor'];

  @override
  String get description =>
      'Set up multi-flavor environment configurations for Android, iOS, Dart, and IDEs';

  FlavorCommand() {
    argParser
      ..addFlag(
        'init',
        help: 'Create a sample flavor.yaml at the project root',
        negatable: false,
      )
      ..addFlag(
        'validate',
        help: 'Validate the existing flavor.yaml configuration file',
        negatable: false,
      )
      ..addOption(
        'config',
        help: 'Path to custom flavor configuration YAML file (default: flavor.yaml)',
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Target project path (defaults to current directory)',
      );
  }

  @override
  Future<int> run() async {
    final logger = Logger();
    final targetPath = argResults?['path'] as String? ?? Directory.current.path;
    final projectPath = p.canonicalize(targetPath);

    final isInit = argResults?['init'] as bool? ?? false;
    final configFile = argResults?['config'] as String? ?? 'flavor.yaml';

    if (isInit) {
      final defaultFile = File(p.join(projectPath, configFile));
      if (await defaultFile.exists()) {
        logger.warn('⚠️ $configFile already exists at project root.');
        return ExitCode.success.code;
      }
      await defaultFile.writeAsString('''flavors:
  dev:
    app:
      name: "Example Dev"
      baseUrl: "https://dev-api.example.com"
    android:
      applicationId: "com.example.app.dev"
    ios:
      bundleId: "com.example.app.dev"

  prod:
    app:
      name: "Example"
      baseUrl: "https://api.example.com"
    android:
      applicationId: "com.example.app"
    ios:
      bundleId: "com.example.app"
''');
      logger.info('${lightGreen.wrap('✨')} Created sample $configFile at project root.');
      return ExitCode.success.code;
    }

    final isValidate = argResults?['validate'] as bool? ?? false;
    final loader = FlavorYamlLoader(projectRoot: projectPath, fileName: configFile);

    try {
      final flavors = await loader.load();

      logger.info(
        '🚀 Loaded ${flavors.length} flavor(s) from $configFile: '
        '${flavors.map((f) => f.name).join(', ')}',
      );

      if (isValidate) {
        logger.info('${lightGreen.wrap('✅')} Configuration in $configFile is valid!');
        return ExitCode.success.code;
      }

      final generator = FlavorGenerator(
        flavors: flavors,
        projectRoot: projectPath,
      );

      await generator.run();
      return ExitCode.success.code;
    } on FlavorConfigException catch (e) {
      logger.err(e.toString());
      return ExitCode.config.code;
    } catch (e, stack) {
      logger.err('❌ Unexpected error while setting up flavors: $e');
      logger.err(stack.toString());
      return ExitCode.software.code;
    }
  }
}
