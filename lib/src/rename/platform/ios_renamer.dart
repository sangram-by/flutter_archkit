import 'dart:io';
import 'package:path/path.dart' as p;
import '../parser/rename_config.dart';

class IosRenamer {
  final RenameConfig config;
  final String projectRoot;

  IosRenamer({required this.config, required this.projectRoot});

  Future<void> run() async {
    final iosDir = Directory(p.join(projectRoot, 'ios'));
    if (!await iosDir.exists()) {
      return;
    }

    if (config.effectiveIosAppName != null) {
      await _updateInfoPlist();
    }
    if (config.effectiveIosBundleId != null) {
      await _updatePbxproj();
    }
  }

  Future<void> _updateInfoPlist() async {
    final plistPath = p.join(projectRoot, 'ios', 'Runner', 'Info.plist');
    final file = File(plistPath);
    if (!await file.exists()) return;

    var content = await file.readAsString();
    final newName = config.effectiveIosAppName;

    // CFBundleDisplayName
    if (content.contains('<key>CFBundleDisplayName</key>')) {
      content = content.replaceAll(
        RegExp(
          r'<key>CFBundleDisplayName<\/key>\s*<string>.*?<\/string>',
          dotAll: true,
        ),
        '<key>CFBundleDisplayName</key>\n\t<string>$newName</string>',
      );
    } else if (content.contains('<dict>')) {
      content = content.replaceFirst(
        '<dict>',
        '<dict>\n\t<key>CFBundleDisplayName</key>\n\t<string>$newName</string>',
      );
    }

    // CFBundleName
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
      'ios',
      'Runner.xcodeproj',
      'project.pbxproj',
    );
    final file = File(pbxPath);
    if (!await file.exists()) return;

    var content = await file.readAsString();
    final newBundleId = config.effectiveIosBundleId;

    // Replace PRODUCT_BUNDLE_IDENTIFIER for runner (avoiding .RunnerTests if present)
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
