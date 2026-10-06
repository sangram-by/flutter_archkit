import 'dart:io';
import 'package:path/path.dart' as p;
import 'parser/rename_config.dart';
import 'parser/rename_yaml_loader.dart';

class RenameToFlavorConverter {
  final String projectRoot;

  RenameToFlavorConverter({this.projectRoot = '.'});

  /// Finds `rename.yaml` or `rename.yml` in [projectRoot] if present.
  static String? findRenameFileName(String projectRoot) {
    if (File(p.join(projectRoot, 'rename.yaml')).existsSync()) {
      return 'rename.yaml';
    }
    if (File(p.join(projectRoot, 'rename.yml')).existsSync()) {
      return 'rename.yml';
    }
    return null;
  }

  /// Converts a [RenameConfig] into a formatted `flavor.yaml` string.
  static String convertToYamlString(RenameConfig config) {
    final appName = config.appName ??
        config.androidAppName ??
        config.iosAppName ??
        'App';
    final androidPkg = config.effectiveAndroidPackageName ??
        config.packageName ??
        'com.example.app';
    final iosPkg = config.effectiveIosBundleId ??
        config.packageName ??
        'com.example.app';

    return '''# Converted from rename configuration by flutter_archkit
flavors:
  dev:
    app:
      name: "$appName Dev"
      baseUrl: "https://dev-api.example.com"
    android:
      applicationId: "$androidPkg.dev"
    ios:
      bundleId: "$iosPkg.dev"

  prod:
    app:
      name: "$appName"
      baseUrl: "https://api.example.com"
    android:
      applicationId: "$androidPkg"
    ios:
      bundleId: "$iosPkg"
''';
  }

  /// Reads rename YAML from [renameFileName], generates [flavorFileName],
  /// and automatically removes the rename file on success.
  Future<String> convertAndSave({
    String renameFileName = 'rename.yaml',
    String flavorFileName = 'flavor.yaml',
    bool overwrite = false,
    bool deleteRenameFile = true,
  }) async {
    final loader = RenameYamlLoader(
      projectRoot: projectRoot,
      fileName: renameFileName,
    );
    final config = await loader.load();

    final flavorFile = File(p.join(projectRoot, flavorFileName));
    if (await flavorFile.exists() && !overwrite) {
      throw StateError(
        '$flavorFileName already exists at "$projectRoot". Use overwrite option if you want to replace it.',
      );
    }

    final content = convertToYamlString(config);
    await flavorFile.writeAsString(content);

    if (deleteRenameFile) {
      final renameFile = File(p.join(projectRoot, renameFileName));
      if (await renameFile.exists()) {
        await renameFile.delete();
      }
    }

    return content;
  }
}
