import 'dart:io';
import 'package:yaml/yaml.dart';
import 'rename_config.dart';
import 'rename_exceptions.dart';

class RenameYamlLoader {
  final String projectRoot;
  final String fileName;

  RenameYamlLoader({this.projectRoot = '.', this.fileName = 'rename.yaml'});

  String get _path => '$projectRoot/$fileName';

  Future<RenameConfig> load() async {
    var file = File(_path);

    if (!await file.exists()) {
      if (fileName == 'rename.yaml') {
        final ymlFile = File('$projectRoot/rename.yml');
        if (await ymlFile.exists()) {
          file = ymlFile;
        } else {
          throw RenameYamlNotFoundException(_path);
        }
      } else {
        throw RenameYamlNotFoundException(_path);
      }
    }

    final raw = await file.readAsString();

    late final YamlDocument doc;
    try {
      doc = loadYamlDocument(raw);
    } on YamlException catch (e) {
      throw RenameYamlParseException('invalid YAML syntax in "$_path" — $e');
    }

    final root = doc.contents.value;
    if (root is! YamlMap || root.isEmpty) {
      throw RenameYamlEmptyException(_path);
    }

    final appName = root['app_name']?.toString().trim();
    final packageName = (root['package_name'] ??
            root['application_id'] ??
            root['bundle_id'])
        ?.toString()
        .trim();

    // Android
    String? androidAppName;
    String? androidPackageName;
    if (root['android'] is YamlMap) {
      final androidMap = root['android'] as YamlMap;
      androidAppName = androidMap['app_name']?.toString().trim();
      androidPackageName = (androidMap['package_name'] ??
              androidMap['application_id'])
          ?.toString()
          .trim();
    }

    // iOS
    String? iosAppName;
    String? iosBundleId;
    if (root['ios'] is YamlMap) {
      final iosMap = root['ios'] as YamlMap;
      iosAppName = iosMap['app_name']?.toString().trim();
      iosBundleId = (iosMap['bundle_id'] ?? iosMap['package_name'])
          ?.toString()
          .trim();
    }

    // Web
    String? webAppName;
    String? webDescription;
    if (root['web'] is YamlMap) {
      final webMap = root['web'] as YamlMap;
      webAppName = webMap['app_name']?.toString().trim();
      webDescription = webMap['description']?.toString().trim();
    }

    // macOS
    String? macosAppName;
    String? macosBundleId;
    if (root['macos'] is YamlMap) {
      final macosMap = root['macos'] as YamlMap;
      macosAppName = macosMap['app_name']?.toString().trim();
      macosBundleId = (macosMap['bundle_id'] ?? macosMap['package_name'])
          ?.toString()
          .trim();
    }

    // Windows
    String? windowsAppName;
    if (root['windows'] is YamlMap) {
      final windowsMap = root['windows'] as YamlMap;
      windowsAppName = windowsMap['app_name']?.toString().trim();
    }

    // Linux
    String? linuxAppName;
    String? linuxPackageName;
    if (root['linux'] is YamlMap) {
      final linuxMap = root['linux'] as YamlMap;
      linuxAppName = linuxMap['app_name']?.toString().trim();
      linuxPackageName = linuxMap['package_name']?.toString().trim();
    }

    final config = RenameConfig(
      appName: (appName != null && appName.isNotEmpty) ? appName : null,
      packageName:
          (packageName != null && packageName.isNotEmpty) ? packageName : null,
      androidAppName:
          (androidAppName != null && androidAppName.isNotEmpty)
              ? androidAppName
              : null,
      androidPackageName:
          (androidPackageName != null && androidPackageName.isNotEmpty)
              ? androidPackageName
              : null,
      iosAppName:
          (iosAppName != null && iosAppName.isNotEmpty) ? iosAppName : null,
      iosBundleId:
          (iosBundleId != null && iosBundleId.isNotEmpty) ? iosBundleId : null,
      webAppName:
          (webAppName != null && webAppName.isNotEmpty) ? webAppName : null,
      webDescription:
          (webDescription != null && webDescription.isNotEmpty)
              ? webDescription
              : null,
      macosAppName:
          (macosAppName != null && macosAppName.isNotEmpty) ? macosAppName : null,
      macosBundleId:
          (macosBundleId != null && macosBundleId.isNotEmpty)
              ? macosBundleId
              : null,
      windowsAppName:
          (windowsAppName != null && windowsAppName.isNotEmpty)
              ? windowsAppName
              : null,
      linuxAppName:
          (linuxAppName != null && linuxAppName.isNotEmpty) ? linuxAppName : null,
      linuxPackageName:
          (linuxPackageName != null && linuxPackageName.isNotEmpty)
              ? linuxPackageName
              : null,
    );

    if (!config.hasAnyChange) {
      throw RenameYamlParseException(
        'No valid configuration found in "$_path".\n'
        'Please specify "app_name", "package_name", or platform-specific overrides (e.g. android:, ios:).',
      );
    }

    return config;
  }
}
