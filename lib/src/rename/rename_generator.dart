import 'dart:io';
import 'package:path/path.dart' as p;
import 'parser/rename_config.dart';
import 'platform/android_renamer.dart';
import 'platform/ios_renamer.dart';
import 'platform/linux_renamer.dart';
import 'platform/macos_renamer.dart';
import 'platform/web_renamer.dart';
import 'platform/windows_renamer.dart';

class RenameGenerator {
  final RenameConfig config;
  final String projectRoot;

  RenameGenerator({required this.config, this.projectRoot = '.'});

  /// Applies app name and package name changes across all existing platforms.
  /// Returns a list of platform names that were detected and updated.
  Future<List<String>> run() async {
    final updatedPlatforms = <String>[];

    // Android
    if (await Directory(p.join(projectRoot, 'android')).exists() &&
        (config.effectiveAndroidAppName != null ||
            config.effectiveAndroidPackageName != null)) {
      await AndroidRenamer(config: config, projectRoot: projectRoot).run();
      updatedPlatforms.add('Android');
    }

    // iOS
    if (await Directory(p.join(projectRoot, 'ios')).exists() &&
        (config.effectiveIosAppName != null ||
            config.effectiveIosBundleId != null)) {
      await IosRenamer(config: config, projectRoot: projectRoot).run();
      updatedPlatforms.add('iOS');
    }

    // Web
    if (await Directory(p.join(projectRoot, 'web')).exists() &&
        (config.effectiveWebAppName != null ||
            config.webDescription != null)) {
      await WebRenamer(config: config, projectRoot: projectRoot).run();
      updatedPlatforms.add('Web');
    }

    // macOS
    if (await Directory(p.join(projectRoot, 'macos')).exists() &&
        (config.effectiveMacosAppName != null ||
            config.effectiveMacosBundleId != null)) {
      await MacosRenamer(config: config, projectRoot: projectRoot).run();
      updatedPlatforms.add('macOS');
    }

    // Windows
    if (await Directory(p.join(projectRoot, 'windows')).exists() &&
        config.effectiveWindowsAppName != null) {
      await WindowsRenamer(config: config, projectRoot: projectRoot).run();
      updatedPlatforms.add('Windows');
    }

    // Linux
    if (await Directory(p.join(projectRoot, 'linux')).exists() &&
        (config.effectiveLinuxAppName != null ||
            config.effectiveLinuxPackageName != null)) {
      await LinuxRenamer(config: config, projectRoot: projectRoot).run();
      updatedPlatforms.add('Linux');
    }

    return updatedPlatforms;
  }
}
