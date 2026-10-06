import 'dart:io';
import 'package:path/path.dart' as p;
import '../parser/rename_config.dart';

class WebRenamer {
  final RenameConfig config;
  final String projectRoot;

  WebRenamer({required this.config, required this.projectRoot});

  Future<void> run() async {
    final webDir = Directory(p.join(projectRoot, 'web'));
    if (!await webDir.exists()) {
      return;
    }

    if (config.effectiveWebAppName != null || config.webDescription != null) {
      await _updateIndexHtml();
      await _updateManifestJson();
    }
  }

  Future<void> _updateIndexHtml() async {
    final indexPath = p.join(projectRoot, 'web', 'index.html');
    final file = File(indexPath);
    if (!await file.exists()) return;

    var content = await file.readAsString();
    final newName = config.effectiveWebAppName;

    // <title>...</title>
    content = content.replaceAll(
      RegExp(r'<title>.*?<\/title>', caseSensitive: false),
      '<title>$newName</title>',
    );

    // apple-mobile-web-app-title
    content = content.replaceAll(
      RegExp(r'<meta\s+name=["\x27]apple-mobile-web-app-title["\x27]\s+content=["\x27].*?["\x27]>', caseSensitive: false),
      '<meta name="apple-mobile-web-app-title" content="$newName">',
    );

    // meta description
    if (config.webDescription != null) {
      final desc = config.webDescription!;
      content = content.replaceAll(
        RegExp(r'<meta\s+name=["\x27]description["\x27]\s+content=["\x27].*?["\x27]>', caseSensitive: false),
        '<meta name="description" content="$desc">',
      );
    }

    await file.writeAsString(content);
  }

  Future<void> _updateManifestJson() async {
    final manifestPath = p.join(projectRoot, 'web', 'manifest.json');
    final file = File(manifestPath);
    if (!await file.exists()) return;

    var content = await file.readAsString();
    final newName = config.effectiveWebAppName;

    content = content.replaceAll(
      RegExp(r'"name":\s*"[^"]*"'),
      '"name": "$newName"',
    );

    content = content.replaceAll(
      RegExp(r'"short_name":\s*"[^"]*"'),
      '"short_name": "$newName"',
    );

    if (config.webDescription != null) {
      content = content.replaceAll(
        RegExp(r'"description":\s*"[^"]*"'),
        '"description": "${config.webDescription}"',
      );
    }

    await file.writeAsString(content);
  }
}
