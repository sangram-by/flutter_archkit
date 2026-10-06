import 'dart:io';
import 'package:path/path.dart' as p;
import '../parser/rename_config.dart';

class AndroidRenamer {
  final RenameConfig config;
  final String projectRoot;

  AndroidRenamer({required this.config, required this.projectRoot});

  Future<void> run() async {
    final androidDir = Directory(p.join(projectRoot, 'android'));
    if (!await androidDir.exists()) {
      return;
    }

    if (config.effectiveAndroidPackageName != null) {
      await _updateBuildGradleKts();
      await _updateBuildGradleGroovy();
      await _updateAndroidManifestPackage();
      await _updateMainActivityAndDirectory();
    }

    if (config.effectiveAndroidAppName != null) {
      await _updateAndroidManifestLabel();
      await _updateStringsXml();
    }
  }

  Future<void> _updateBuildGradleKts() async {
    final file = File(p.join(projectRoot, 'android', 'app', 'build.gradle.kts'));
    if (!await file.exists()) return;

    var content = await file.readAsString();
    final newPkg = config.effectiveAndroidPackageName!;

    // applicationId = "..."
    content = content.replaceAll(
      RegExp(r'applicationId\s*=\s*["\x27][^"\x27]+["\x27]'),
      'applicationId = "$newPkg"',
    );

    // namespace = "..."
    content = content.replaceAll(
      RegExp(r'namespace\s*=\s*["\x27][^"\x27]+["\x27]'),
      'namespace = "$newPkg"',
    );

    await file.writeAsString(content);
  }

  Future<void> _updateBuildGradleGroovy() async {
    final file = File(p.join(projectRoot, 'android', 'app', 'build.gradle'));
    if (!await file.exists()) return;

    var content = await file.readAsString();
    final newPkg = config.effectiveAndroidPackageName!;

    // applicationId "..." or applicationId = "..."
    content = content.replaceAllMapped(
      RegExp(r'applicationId(\s*=?\s*)["\x27][^"\x27]+["\x27]'),
      (m) => 'applicationId${m[1]}"$newPkg"',
    );

    // namespace "..." or namespace = "..."
    content = content.replaceAllMapped(
      RegExp(r'namespace(\s*=?\s*)["\x27][^"\x27]+["\x27]'),
      (m) => 'namespace${m[1]}"$newPkg"',
    );

    await file.writeAsString(content);
  }

  Future<void> _updateAndroidManifestPackage() async {
    final manifestPath = p.join(
      projectRoot,
      'android',
      'app',
      'src',
      'main',
      'AndroidManifest.xml',
    );
    final file = File(manifestPath);
    if (!await file.exists()) return;

    var content = await file.readAsString();
    final newPkg = config.effectiveAndroidPackageName!;

    content = content.replaceAll(
      RegExp(r'package\s*=\s*["\x27][^"\x27]+["\x27]'),
      'package="$newPkg"',
    );

    await file.writeAsString(content);
  }

  Future<void> _updateAndroidManifestLabel() async {
    final manifestPath = p.join(
      projectRoot,
      'android',
      'app',
      'src',
      'main',
      'AndroidManifest.xml',
    );
    final file = File(manifestPath);
    if (!await file.exists()) return;

    var content = await file.readAsString();
    final newName = config.effectiveAndroidAppName!;

    // Update android:label only if it's not referencing a string resource
    if (content.contains('android:label="') &&
        !content.contains('android:label="@string/')) {
      content = content.replaceAll(
        RegExp(r'android:label\s*=\s*["\x27][^"\x27]+["\x27]'),
        'android:label="$newName"',
      );
      await file.writeAsString(content);
    }
  }

  Future<void> _updateStringsXml() async {
    final stringsFile = File(
      p.join(
        projectRoot,
        'android',
        'app',
        'src',
        'main',
        'res',
        'values',
        'strings.xml',
      ),
    );
    final newName = config.effectiveAndroidAppName!;

    if (await stringsFile.exists()) {
      var content = await stringsFile.readAsString();
      if (content.contains('<string name="app_name">')) {
        content = content.replaceAll(
          RegExp(r'<string name="app_name">.*?</string>'),
          '<string name="app_name">$newName</string>',
        );
      } else if (content.contains('</resources>')) {
        content = content.replaceFirst(
          '</resources>',
          '    <string name="app_name">$newName</string>\n</resources>',
        );
      }
      await stringsFile.writeAsString(content);
    } else {
      // Check if AndroidManifest references @string/app_name
      final manifestPath = p.join(
        projectRoot,
        'android',
        'app',
        'src',
        'main',
        'AndroidManifest.xml',
      );
      final manifestFile = File(manifestPath);
      if (await manifestFile.exists()) {
        final manifestContent = await manifestFile.readAsString();
        if (manifestContent.contains('@string/app_name')) {
          await stringsFile.parent.create(recursive: true);
          await stringsFile.writeAsString('''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">$newName</string>
</resources>
''');
        }
      }
    }
  }

  Future<void> _updateMainActivityAndDirectory() async {
    final newPkg = config.effectiveAndroidPackageName!;
    final codeRoots = [
      p.join(projectRoot, 'android', 'app', 'src', 'main', 'kotlin'),
      p.join(projectRoot, 'android', 'app', 'src', 'main', 'java'),
    ];

    for (final rootPath in codeRoots) {
      final rootDir = Directory(rootPath);
      if (!await rootDir.exists()) continue;

      final entities = rootDir.listSync(recursive: true);
      for (final entity in entities) {
        if (entity is File &&
            (entity.path.endsWith('MainActivity.kt') ||
                entity.path.endsWith('MainActivity.java'))) {
          var content = await entity.readAsString();
          content = content.replaceAll(
            RegExp(r'package\s+[a-zA-Z0-9_.]+'),
            'package $newPkg',
          );
          await entity.writeAsString(content);

          // Move MainActivity to new folder hierarchy
          final isKotlin = entity.path.endsWith('.kt');
          final fileName = isKotlin ? 'MainActivity.kt' : 'MainActivity.java';
          final newDirParts = newPkg.split('.');
          final targetDirectoryPath = p.joinAll([rootPath, ...newDirParts]);
          final targetFilePath = p.join(targetDirectoryPath, fileName);

          if (p.canonicalize(entity.path) !=
              p.canonicalize(targetFilePath)) {
            final oldParent = entity.parent;
            await Directory(targetDirectoryPath).create(recursive: true);
            await entity.copy(targetFilePath);
            await entity.delete();

            // Clean up empty old directory trees
            _cleanEmptyDirs(oldParent, rootDir);
          }
        }
      }
    }
  }

  void _cleanEmptyDirs(Directory dir, Directory stopAt) {
    var current = dir;
    while (p.canonicalize(current.path) != p.canonicalize(stopAt.path) &&
        current.existsSync() &&
        current.listSync().isEmpty) {
      final parent = current.parent;
      try {
        current.deleteSync();
      } catch (_) {
        break;
      }
      current = parent;
    }
  }
}
