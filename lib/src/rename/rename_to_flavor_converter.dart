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
  /// Supports platform-specific app names for Android and iOS when present.
  static String convertToYamlString(RenameConfig config) {
    final baseAppName = config.appName ??
        config.androidAppName ??
        config.iosAppName ??
        'App';

    final androidDevPkg =
        '${config.effectiveAndroidPackageName ?? "com.example.app"}.dev';
    final iosDevPkg =
        '${config.effectiveIosBundleId ?? "com.example.app"}.dev';
    final androidProdPkg =
        config.effectiveAndroidPackageName ?? "com.example.app";
    final iosProdPkg =
        config.effectiveIosBundleId ?? "com.example.app";

    final buffer = StringBuffer();
    buffer.writeln('# Converted from rename configuration by flutter_archkit');
    buffer.writeln('flavors:');
    buffer.writeln('  dev:');
    buffer.writeln('    app:');
    buffer.writeln('      name: "$baseAppName Dev"');
    buffer.writeln('      baseUrl: "https://dev-api.example.com"');
    buffer.writeln('    android:');
    buffer.writeln('      applicationId: "$androidDevPkg"');
    if (config.androidAppName != null) {
      buffer.writeln('      appName: "${config.androidAppName} Dev"');
    }
    buffer.writeln('    ios:');
    buffer.writeln('      bundleId: "$iosDevPkg"');
    if (config.iosAppName != null) {
      buffer.writeln('      appName: "${config.iosAppName} Dev"');
    }
    buffer.writeln();
    buffer.writeln('  prod:');
    buffer.writeln('    app:');
    buffer.writeln('      name: "$baseAppName"');
    buffer.writeln('      baseUrl: "https://api.example.com"');
    buffer.writeln('    android:');
    buffer.writeln('      applicationId: "$androidProdPkg"');
    if (config.androidAppName != null) {
      buffer.writeln('      appName: "${config.androidAppName}"');
    }
    buffer.writeln('    ios:');
    buffer.writeln('      bundleId: "$iosProdPkg"');
    if (config.iosAppName != null) {
      buffer.writeln('      appName: "${config.iosAppName}"');
    }

    return buffer.toString();
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
