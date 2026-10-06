import 'dart:io';
import 'package:flutter_archkit/src/rename/parser/rename_exceptions.dart';
import 'package:flutter_archkit/src/rename/parser/rename_yaml_loader.dart';
import 'package:flutter_archkit/src/rename/rename_generator.dart';

/// Usage:
///   dart run flutter_archkit:rename
///   dart run flutter_archkit:rename --init
///   dart run flutter_archkit:rename --validate
///   dart run flutter_archkit:rename --config=custom_rename.yaml
Future<void> main(List<String> args) async {
  final projectRoot = Directory.current.path;

  final configArg = args.firstWhere(
    (a) => a.startsWith('--config='),
    orElse: () => '',
  );
  final fileName = configArg.isNotEmpty
      ? configArg.split('=').last
      : 'rename.yaml';

  if (args.contains('--help') || args.contains('-h')) {
    stdout.writeln('''
Rename application display name and package/bundle identifier across all platforms.

Usage: dart run flutter_archkit:rename [options]

Options:
  --init          Create a sample rename.yaml configuration file at the project root
  --validate      Validate the existing rename.yaml configuration file
  --config=<file> Custom rename configuration YAML file (default: rename.yaml)
  -h, --help      Show this help message
''');
    return;
  }

  if (args.contains('--init')) {
    final defaultFile = File(fileName);
    if (await defaultFile.exists()) {
      stdout.writeln('⚠️ $fileName already exists at project root.');
      return;
    }

    final flavorFile = File('flavor.yaml');
    final flavorYml = File('flavor.yml');
    if (await flavorFile.exists() || await flavorYml.exists()) {
      stdout.writeln(
        '⚠️ This project already uses multi-flavors (flavor.yaml).\n'
        '   App names and package configurations are managed via flavors.\n'
        '   👉 Run "dart run flutter_archkit:setup_flavor" to apply changes.',
      );
      return;
    }

    await defaultFile.writeAsString('''# flutter_archkit App & Package Rename Configuration
# Run "dart run flutter_archkit:rename" to apply changes across all platforms.
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
    stdout.writeln('✨ Created sample $fileName at project root.');
    return;
  }

  // If rename file does not exist, check if flavor file exists
  if (!await File(fileName).exists() && !await File('rename.yml').exists()) {
    final flavorFile = File('flavor.yaml');
    final flavorYmlFile = File('flavor.yml');
    if (await flavorFile.exists() || await flavorYmlFile.exists()) {
      stdout.writeln(
        'ℹ️ Found flavor.yaml! This project uses multi-flavor environments.\n'
        '   App names and bundle identifiers are managed via flavor configurations.\n'
        '   👉 Run "dart run flutter_archkit:setup_flavor" to update and apply flavor setups.',
      );
      return;
    }
  }

  final loader = RenameYamlLoader(projectRoot: projectRoot, fileName: fileName);

  try {
    final config = await loader.load();

    if (args.contains('--validate')) {
      stdout.writeln('✅ Configuration in $fileName is valid!');
      if (config.appName != null) stdout.writeln('   App Name: ${config.appName}');
      if (config.packageName != null) stdout.writeln('   Package/Bundle ID: ${config.packageName}');
      if (config.androidAppName != null) stdout.writeln('   Android App Name: ${config.androidAppName}');
      if (config.androidPackageName != null) stdout.writeln('   Android Package: ${config.androidPackageName}');
      if (config.iosAppName != null) stdout.writeln('   iOS App Name: ${config.iosAppName}');
      if (config.iosBundleId != null) stdout.writeln('   iOS Bundle ID: ${config.iosBundleId}');
      return;
    }

    final appNameDisplay = config.appName ??
        config.androidAppName ??
        config.iosAppName ??
        '(Platform-specific)';
    final pkgNameDisplay = config.packageName ??
        config.androidPackageName ??
        config.iosBundleId ??
        '(Platform-specific)';

    stdout.writeln(
      '🚀 Applying rename configuration from $fileName:\n'
      '   • App Name: $appNameDisplay\n'
      '   • Package ID: $pkgNameDisplay',
    );

    final generator = RenameGenerator(
      config: config,
      projectRoot: projectRoot,
    );

    final updated = await generator.run();

    if (updated.isEmpty) {
      stdout.writeln(
        '⚠️ No platform directories (android, ios, web, macos, windows, linux) found in $projectRoot.',
      );
    } else {
      stdout.writeln('✅ Successfully updated platforms: ${updated.join(', ')}');
    }
  } on RenameConfigException catch (e) {
    stderr.writeln(e.toString());
    exit(1);
  } catch (e, stack) {
    stderr.writeln('❌ Unexpected error while renaming package/app: $e');
    stderr.writeln(stack);
    exit(1);
  }
}
