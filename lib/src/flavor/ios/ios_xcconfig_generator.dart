import 'dart:io';

import '../parser/flavor_config.dart';

/// Generates per-flavor .xcconfig files in ios/Flutter directory and updates base xcconfigs.
class IosXcconfigGenerator {
  final List<FlavorConfig> flavors;
  final String projectRoot;

  IosXcconfigGenerator({required this.flavors, required this.projectRoot});

  Future<void> run() async {
    final flavorsDir = Directory('$projectRoot/ios/Flutter');
    if (!await flavorsDir.exists()) {
      await flavorsDir.create(recursive: true);
    }

    const configs = ['Debug', 'Profile', 'Release'];

    for (final flavor in flavors) {
      for (final config in configs) {
        final file = File('${flavorsDir.path}/$config-${flavor.name}.xcconfig');

        // Profile builds in Flutter inherit from Debug.xcconfig by default
        final includeConfig = config == 'Profile' ? 'Debug' : config;
        final podConfigName = '${config.toLowerCase()}-${flavor.name}';

        final content =
            '''
#include "$includeConfig.xcconfig"
#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.$podConfigName.xcconfig"

FLUTTER_TARGET=lib/main.dart
APP_NAME=${flavor.effectiveIosAppName}
BASE_URL=${flavor.baseUrl}
PRODUCT_BUNDLE_IDENTIFIER=${flavor.bundleId}
''';

        await file.writeAsString(content);
        stdout.writeln('Created ${file.path}');
      }
    }

    await _patchBaseXcconfigs(flavorsDir);
  }

  Future<void> _patchBaseXcconfigs(Directory flavorsDir) async {
    for (final mode in ['Debug', 'Release']) {
      final file = File('${flavorsDir.path}/$mode.xcconfig');
      if (await file.exists()) {
        String content = await file.readAsString();
        final podInclude =
            '#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.${mode.toLowerCase()}.xcconfig"';
        if (!content.contains(podInclude)) {
          if (content.isNotEmpty && !content.endsWith('\n')) {
            content += '\n';
          }
          content += '$podInclude\n';
          await file.writeAsString(content);
          stdout.writeln('✏️  Updated ${file.path}');
        }
      }
    }
  }
}
