import 'dart:io';
import 'package:path/path.dart' as p;
import '../parser/rename_config.dart';

class LinuxRenamer {
  final RenameConfig config;
  final String projectRoot;

  LinuxRenamer({required this.config, required this.projectRoot});

  Future<void> run() async {
    final linuxDir = Directory(p.join(projectRoot, 'linux'));
    if (!await linuxDir.exists()) {
      return;
    }

    if (config.effectiveLinuxAppName != null) {
      await _updateMyApplicationCc();
    }
    if (config.effectiveLinuxPackageName != null) {
      await _updateCMakeListsTxt();
    }
  }

  Future<void> _updateMyApplicationCc() async {
    final ccPath = p.join(projectRoot, 'linux', 'my_application.cc');
    final file = File(ccPath);
    if (!await file.exists()) return;

    var content = await file.readAsString();
    final newName = config.effectiveLinuxAppName;

    content = content.replaceAll(
      RegExp(r'gtk_header_bar_set_title\(GTK_HEADER_BAR\(header_bar\),\s*".*?"\)'),
      'gtk_header_bar_set_title(GTK_HEADER_BAR(header_bar), "$newName")',
    );

    content = content.replaceAll(
      RegExp(r'gtk_window_set_title\(GTK_WINDOW\(window\),\s*".*?"\)'),
      'gtk_window_set_title(GTK_WINDOW(window), "$newName")',
    );

    await file.writeAsString(content);
  }

  Future<void> _updateCMakeListsTxt() async {
    final cmakePath = p.join(projectRoot, 'linux', 'CMakeLists.txt');
    final file = File(cmakePath);
    if (!await file.exists()) return;

    var content = await file.readAsString();
    final newPkg = config.effectiveLinuxPackageName;

    content = content.replaceAll(
      RegExp(r'set\(APPLICATION_ID\s+".*?"\)'),
      'set(APPLICATION_ID "$newPkg")',
    );

    await file.writeAsString(content);
  }
}
