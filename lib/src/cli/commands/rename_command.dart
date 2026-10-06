import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_archkit/src/rename/parser/rename_exceptions.dart';
import 'package:flutter_archkit/src/rename/parser/rename_yaml_loader.dart';
import 'package:flutter_archkit/src/rename/rename_generator.dart';

class RenameCommand extends Command<int> {
  @override
  String get name => 'rename';

  @override
  List<String> get aliases => const ['app_name', 'set_name', 'change_name'];

  @override
  String get description =>
      'Rename application display name and package/bundle identifier across all platforms';

  RenameCommand() {
    argParser
      ..addFlag(
        'init',
        help: 'Create a sample rename.yaml configuration file at the project root',
        negatable: false,
      )
      ..addFlag(
        'validate',
        help: 'Validate the existing rename.yaml configuration file',
        negatable: false,
      )
      ..addOption(
        'config',
        help: 'Path to custom rename configuration YAML file (default: rename.yaml)',
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
    final isValidate = argResults?['validate'] as bool? ?? false;
    final configFile = argResults?['config'] as String? ?? 'rename.yaml';

    if (isInit) {
      final defaultFile = File(p.join(projectPath, configFile));
      if (await defaultFile.exists()) {
        logger.warn('⚠️ $configFile already exists at project root.');
        return ExitCode.success.code;
      }

      final flavorFile = File(p.join(projectPath, 'flavor.yaml'));
      final flavorYml = File(p.join(projectPath, 'flavor.yml'));
      if (await flavorFile.exists() || await flavorYml.exists()) {
        logger.warn(
          '⚠️ This project already uses multi-flavors (flavor.yaml).\n'
          '   App names and package configurations are managed via flavors.\n'
          '   👉 Run "archkit flavor" to apply changes.',
        );
        return ExitCode.success.code;
      }

      await defaultFile.writeAsString('''# flutter_archkit App & Package Rename Configuration
# Run "archkit rename" to apply this configuration to all platforms.
# Run "archkit flavor --init" if you want to switch to multi-flavor environments.

app_name: "My Awesome App"
package_name: "com.example.my_awesome_app"

# Optional: Platform-specific overrides
# android:
#   app_name: "My Awesome App Android"
#   package_name: "com.example.my_awesome_app"
# ios:
#   app_name: "My Awesome App iOS"
#   bundle_id: "com.example.my_awesome_app"
# web:
#   app_name: "My Awesome App Web"
#   description: "My Awesome App Web Application"
# macos:
#   app_name: "My Awesome App macOS"
#   bundle_id: "com.example.my_awesome_app"
# windows:
#   app_name: "My Awesome App Windows"
# linux:
#   app_name: "My Awesome App Linux"
#   package_name: "com.example.my_awesome_app"
''');
      logger.info('${lightGreen.wrap('✨')} Created sample $configFile at project root.');
      return ExitCode.success.code;
    }

    // If rename file doesn't exist, check if flavor file exists
    final renameFile = File(p.join(projectPath, configFile));
    final renameYmlFile = File(p.join(projectPath, 'rename.yml'));
    if (!await renameFile.exists() && !await renameYmlFile.exists()) {
      final flavorFile = File(p.join(projectPath, 'flavor.yaml'));
      final flavorYmlFile = File(p.join(projectPath, 'flavor.yml'));
      if (await flavorFile.exists() || await flavorYmlFile.exists()) {
        logger.info(
          'ℹ️ Found flavor.yaml! This project uses multi-flavor environments.\n'
          '   App names and bundle identifiers are managed via flavor configurations.\n'
          '   👉 Run "archkit flavor" to update and apply flavor setups.',
        );
        return ExitCode.success.code;
      }
    }

    final loader = RenameYamlLoader(projectRoot: projectPath, fileName: configFile);

    try {
      final config = await loader.load();

      if (isValidate) {
        logger.info('${lightGreen.wrap('✅')} Configuration in $configFile is valid!');
        if (config.appName != null) logger.info('   App Name: ${config.appName}');
        if (config.packageName != null) logger.info('   Package/Bundle ID: ${config.packageName}');
        if (config.androidAppName != null) logger.info('   Android App Name: ${config.androidAppName}');
        if (config.androidPackageName != null) logger.info('   Android Package: ${config.androidPackageName}');
        if (config.iosAppName != null) logger.info('   iOS App Name: ${config.iosAppName}');
        if (config.iosBundleId != null) logger.info('   iOS Bundle ID: ${config.iosBundleId}');
        return ExitCode.success.code;
      }

      final appNameDisplay = config.appName ??
          config.androidAppName ??
          config.iosAppName ??
          '(Platform-specific)';
      final pkgNameDisplay = config.packageName ??
          config.androidPackageName ??
          config.iosBundleId ??
          '(Platform-specific)';

      logger.info(
        '🚀 Applying rename configuration from $configFile:\n'
        '   • App Name: $appNameDisplay\n'
        '   • Package ID: $pkgNameDisplay',
      );

      final generator = RenameGenerator(
        config: config,
        projectRoot: projectPath,
      );

      final updated = await generator.run();

      if (updated.isEmpty) {
        logger.warn(
          '⚠️ No platform directories (android, ios, web, macos, windows, linux) found in $projectPath.',
        );
      } else {
        logger.info(
          '${lightGreen.wrap('✅')} Successfully updated platforms: ${updated.join(', ')}',
        );
      }

      return ExitCode.success.code;
    } on RenameConfigException catch (e) {
      logger.err(e.toString());
      return ExitCode.config.code;
    } catch (e, stack) {
      logger.err('❌ Unexpected error while renaming package/app: $e');
      logger.err(stack.toString());
      return ExitCode.software.code;
    }
  }
}
