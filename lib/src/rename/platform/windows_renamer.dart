import 'dart:io';
import 'package:path/path.dart' as p;
import '../parser/rename_config.dart';

class WindowsRenamer {
  final RenameConfig config;
  final String projectRoot;

  WindowsRenamer({required this.config, required this.projectRoot});

  Future<void> run() async {
    final windowsDir = Directory(p.join(projectRoot, 'windows'));
    if (!await windowsDir.exists()) {
      return;
    }

    if (config.effectiveWindowsAppName != null) {
      await _updateRunnerRc();
      await _updateMainCpp();
    }
  }

  Future<void> _updateRunnerRc() async {
    final rcPath = p.join(projectRoot, 'windows', 'runner', 'Runner.rc');
    final file = File(rcPath);
    if (!await file.exists()) return;

    var content = await file.readAsString();
    final newName = config.effectiveWindowsAppName;

    content = content.replaceAll(
      RegExp(r'VALUE\s+"FileDescription",\s*".*?"'),
      'VALUE "FileDescription", "$newName"',
    );

    content = content.replaceAll(
      RegExp(r'VALUE\s+"InternalName",\s*".*?"'),
      'VALUE "InternalName", "$newName"',
    );

    content = content.replaceAll(
      RegExp(r'VALUE\s+"ProductName",\s*".*?"'),
      'VALUE "ProductName", "$newName"',
    );

    await file.writeAsString(content);
  }

  Future<void> _updateMainCpp() async {
    final mainCppPath = p.join(projectRoot, 'windows', 'runner', 'main.cpp');
    final file = File(mainCppPath);
    if (!await file.exists()) return;

    var content = await file.readAsString();
    final newName = config.effectiveWindowsAppName;

    // window.Create(L"Old Name", ... or window.CreateAndShow(L"Old Name", ...
    content = content.replaceAllMapped(
      RegExp(r'window\.Create(AndShow)?\(L".*?",'),
      (m) => 'window.Create${m[1] ?? ""}(L"$newName",',
    );

    await file.writeAsString(content);
  }
}
