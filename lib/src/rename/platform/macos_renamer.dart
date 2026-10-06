import 'dart:io';
import 'package:path/path.dart' as p;
import '../parser/rename_config.dart';

class MacosRenamer {
  final RenameConfig config;
  final String projectRoot;

  MacosRenamer({required this.config, required this.projectRoot});

  Future<void> run() async {
    final macosDir = Directory(p.join(projectRoot, 'macos'));
    if (!await macosDir.exists()) {
      return;
    }

    if (config.effectiveMacosAppName != null ||
        config.effectiveMacosBundleId != null) {
      await _updateAppInfoXcconfig();
    }
    if (config.effectiveMacosAppName != null) {
      await _updateInfoPlist();
    }
    if (config.effectiveMacosBundleId != null) {
      await _updatePbxproj();
    }
  }

  Future<void> _updateAppInfoXcconfig() async {
    final xcconfigPath = p.join(
      projectRoot,
      'macos',
      'Runner',
      'Configs',
      'AppInfo.xcconfig',
    );
    final file = File(xcconfigPath);
    if (!await file.exists()) return;

    var content = await file.readAsString();
    final newName = config.effectiveMacosAppName;
    final newBundleId = config.effectiveMacosBundleId;

    if (newName != null) {
      content = content.replaceAll(
        RegExp(r'PRODUCT_NAME\s*=\s*.*'),
        'PRODUCT_NAME = $newName',
      );
    }

    if (newBundleId != null) {
      content = content.replaceAll(
        RegExp(r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*.*'),
        'PRODUCT_BUNDLE_IDENTIFIER = $newBundleId',
      );
    }

    await file.writeAsString(content);
  }

  Future<void> _updateInfoPlist() async {
    final plistPath = p.join(projectRoot, 'macos', 'Runner', 'Info.plist');
    final file = File(plistPath);
    if (!await file.exists()) return;

    var content = await file.readAsString();
    final newName = config.effectiveMacosAppName;

    if (content.contains('<key>CFBundleName</key>')) {
      content = content.replaceAll(
        RegExp(
          r'<key>CFBundleName<\/key>\s*<string>.*?<\/string>',
          dotAll: true,
        ),
        '<key>CFBundleName</key>\n\t<string>$newName</string>',
      );
    }

    await file.writeAsString(content);
  }

  Future<void> _updatePbxproj() async {
    final pbxPath = p.join(
      projectRoot,
      'macos',
      'Runner.xcodeproj',
      'project.pbxproj',
    );
    final file = File(pbxPath);
    if (!await file.exists()) return;

    var content = await file.readAsString();
    final newBundleId = config.effectiveMacosBundleId;

    final lines = content.split('\n');
    final updatedLines = <String>[];

    for (final line in lines) {
      if (line.contains('PRODUCT_BUNDLE_IDENTIFIER') &&
          !line.contains('RunnerTests')) {
        final leadingWs = RegExp(r'^\s*').stringMatch(line) ?? '';
        updatedLines.add('${leadingWs}PRODUCT_BUNDLE_IDENTIFIER = $newBundleId;');
      } else {
        updatedLines.add(line);
      }
    }

    await file.writeAsString(updatedLines.join('\n'));
  }
}
