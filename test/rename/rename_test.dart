import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:flutter_archkit/flutter_archkit.dart';
import 'package:flutter_archkit/src/cli/commands/flavor_command.dart';
import 'package:flutter_archkit/src/cli/commands/rename_command.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('rename_test_');
  });

  tearDown(() async {
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  group('RenameYamlLoader', () {
    test('loads basic rename.yaml configuration correctly', () async {
      final yamlFile = File(p.join(tempDir.path, 'rename.yaml'));
      await yamlFile.writeAsString('''
app_name: "Super App"
package_name: "com.super.app"
''');

      final loader = RenameYamlLoader(projectRoot: tempDir.path);
      final config = await loader.load();

      expect(config.appName, equals('Super App'));
      expect(config.packageName, equals('com.super.app'));
      expect(config.effectiveAndroidAppName, equals('Super App'));
      expect(config.effectiveAndroidPackageName, equals('com.super.app'));
      expect(config.effectiveIosAppName, equals('Super App'));
      expect(config.effectiveIosBundleId, equals('com.super.app'));
      expect(config.effectiveWebAppName, equals('Super App'));
      expect(config.effectiveMacosAppName, equals('Super App'));
      expect(config.effectiveWindowsAppName, equals('Super App'));
      expect(config.effectiveLinuxAppName, equals('Super App'));
    });

    test('loads platform-specific overrides correctly', () async {
      final yamlFile = File(p.join(tempDir.path, 'custom.yaml'));
      await yamlFile.writeAsString('''
app_name: "Base App"
package_name: "com.base.app"
android:
  app_name: "Android App"
  package_name: "com.custom.android"
ios:
  app_name: "iOS App"
  bundle_id: "com.custom.ios"
web:
  app_name: "Web App"
  description: "Web description"
macos:
  app_name: "macOS App"
  bundle_id: "com.custom.macos"
windows:
  app_name: "Windows App"
linux:
  app_name: "Linux App"
  package_name: "com.custom.linux"
''');

      final loader = RenameYamlLoader(
        projectRoot: tempDir.path,
        fileName: 'custom.yaml',
      );
      final config = await loader.load();

      expect(config.appName, equals('Base App'));
      expect(config.packageName, equals('com.base.app'));
      expect(config.effectiveAndroidAppName, equals('Android App'));
      expect(config.effectiveAndroidPackageName, equals('com.custom.android'));
      expect(config.effectiveIosAppName, equals('iOS App'));
      expect(config.effectiveIosBundleId, equals('com.custom.ios'));
      expect(config.effectiveWebAppName, equals('Web App'));
      expect(config.webDescription, equals('Web description'));
      expect(config.effectiveMacosAppName, equals('macOS App'));
      expect(config.effectiveMacosBundleId, equals('com.custom.macos'));
      expect(config.effectiveWindowsAppName, equals('Windows App'));
      expect(config.effectiveLinuxAppName, equals('Linux App'));
      expect(config.effectiveLinuxPackageName, equals('com.custom.linux'));
    });

    test('loads platform-only configuration without top-level keys', () async {
      final yamlFile = File(p.join(tempDir.path, 'platform_only.yaml'));
      await yamlFile.writeAsString('''
android:
  app_name: "Android Awesome App"
  package_name: "com.example.android_app"
ios:
  app_name: "iOS Awesome App"
  bundle_id: "com.example.ios_app"
''');

      final loader = RenameYamlLoader(
        projectRoot: tempDir.path,
        fileName: 'platform_only.yaml',
      );
      final config = await loader.load();

      expect(config.appName, isNull);
      expect(config.packageName, isNull);
      expect(config.effectiveAndroidAppName, equals('Android Awesome App'));
      expect(config.effectiveAndroidPackageName, equals('com.example.android_app'));
      expect(config.effectiveIosAppName, equals('iOS Awesome App'));
      expect(config.effectiveIosBundleId, equals('com.example.ios_app'));
    });

    test('throws RenameYamlNotFoundException when file is missing', () async {
      final loader = RenameYamlLoader(
        projectRoot: tempDir.path,
        fileName: 'missing.yaml',
      );
      expect(() => loader.load(), throwsA(isA<RenameYamlNotFoundException>()));
    });

    test('throws RenameYamlParseException when no valid fields are present', () async {
      final yamlFile = File(p.join(tempDir.path, 'rename.yaml'));
      await yamlFile.writeAsString('unknown_key: "value"\n');

      final loader = RenameYamlLoader(projectRoot: tempDir.path);
      expect(() => loader.load(), throwsA(isA<RenameYamlParseException>()));
    });
  });

  group('RenameToFlavorConverter', () {
    test('converts RenameConfig into flavor.yaml string', () {
      const config = RenameConfig(
        appName: 'Cool App',
        packageName: 'com.cool.app',
      );

      final yaml = RenameToFlavorConverter.convertToYamlString(config);

      expect(yaml, contains('name: "Cool App Dev"'));
      expect(yaml, contains('applicationId: "com.cool.app.dev"'));
      expect(yaml, contains('bundleId: "com.cool.app.dev"'));
      expect(yaml, contains('name: "Cool App"'));
      expect(yaml, contains('applicationId: "com.cool.app"'));
      expect(yaml, contains('bundleId: "com.cool.app"'));
    });

    test('converts platform-specific app names into flavor.yaml with appName overrides', () {
      const config = RenameConfig(
        androidAppName: 'Aritra Android',
        androidPackageName: 'com.example.aritra_android',
        iosAppName: 'Aritra iOS',
        iosBundleId: 'com.example.aritra_ios',
      );

      final yaml = RenameToFlavorConverter.convertToYamlString(config);

      expect(yaml, contains('applicationId: "com.example.aritra_android.dev"'));
      expect(yaml, contains('appName: "Aritra Android Dev"'));
      expect(yaml, contains('bundleId: "com.example.aritra_ios.dev"'));
      expect(yaml, contains('appName: "Aritra iOS Dev"'));
      expect(yaml, contains('applicationId: "com.example.aritra_android"'));
      expect(yaml, contains('appName: "Aritra Android"'));
      expect(yaml, contains('bundleId: "com.example.aritra_ios"'));
      expect(yaml, contains('appName: "Aritra iOS"'));
    });

    test('convertAndSave creates flavor.yaml from rename.yaml', () async {
      final renameFile = File(p.join(tempDir.path, 'rename.yaml'));
      await renameFile.writeAsString('''
app_name: "Cool App"
package_name: "com.cool.app"
''');

      final converter = RenameToFlavorConverter(projectRoot: tempDir.path);
      await converter.convertAndSave();

      final flavorFile = File(p.join(tempDir.path, 'flavor.yaml'));
      expect(await flavorFile.exists(), isTrue);

      // Verify that flavor.yaml can be parsed by FlavorYamlLoader
      final flavorLoader = FlavorYamlLoader(projectRoot: tempDir.path);
      final flavors = await flavorLoader.load();
      expect(flavors.length, equals(2));
      expect(flavors.map((f) => f.name), containsAll(['dev', 'prod']));
    });
  });

  group('RenameGenerator on all platforms', () {
    test('updates Android, iOS, Web, macOS, Windows, Linux files correctly', () async {
      // 1. Setup Android files
      final androidAppDir = Directory(p.join(tempDir.path, 'android', 'app'));
      await androidAppDir.create(recursive: true);

      final buildGradleKts = File(p.join(androidAppDir.path, 'build.gradle.kts'));
      await buildGradleKts.writeAsString('''
namespace = "com.old.app"
defaultConfig {
    applicationId = "com.old.app"
}
''');

      final manifestDir = Directory(
        p.join(androidAppDir.path, 'src', 'main'),
      );
      await manifestDir.create(recursive: true);
      final manifestFile = File(p.join(manifestDir.path, 'AndroidManifest.xml'));
      await manifestFile.writeAsString('''<manifest package="com.old.app">
    <application android:label="Old App">
    </application>
</manifest>
''');

      final kotlinDir = Directory(
        p.join(androidAppDir.path, 'src', 'main', 'kotlin', 'com', 'old', 'app'),
      );
      await kotlinDir.create(recursive: true);
      final mainActivityFile = File(p.join(kotlinDir.path, 'MainActivity.kt'));
      await mainActivityFile.writeAsString('''package com.old.app

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
}
''');

      // 2. Setup iOS files
      final iosRunnerDir = Directory(p.join(tempDir.path, 'ios', 'Runner'));
      await iosRunnerDir.create(recursive: true);
      final infoPlist = File(p.join(iosRunnerDir.path, 'Info.plist'));
      await infoPlist.writeAsString('''<dict>
    <key>CFBundleDisplayName</key>
    <string>Old App</string>
    <key>CFBundleName</key>
    <string>Old App</string>
</dict>
''');

      final iosProjDir = Directory(p.join(tempDir.path, 'ios', 'Runner.xcodeproj'));
      await iosProjDir.create(recursive: true);
      final pbxproj = File(p.join(iosProjDir.path, 'project.pbxproj'));
      await pbxproj.writeAsString('''
				PRODUCT_BUNDLE_IDENTIFIER = com.old.app;
				PRODUCT_BUNDLE_IDENTIFIER = com.old.app.RunnerTests;
''');

      // 3. Setup Web files
      final webDir = Directory(p.join(tempDir.path, 'web'));
      await webDir.create(recursive: true);
      final webIndex = File(p.join(webDir.path, 'index.html'));
      await webIndex.writeAsString('''<!DOCTYPE html>
<html>
<head>
  <title>Old Web App</title>
  <meta name="apple-mobile-web-app-title" content="Old Web App">
</head>
</html>
''');
      final webManifest = File(p.join(webDir.path, 'manifest.json'));
      await webManifest.writeAsString('''{
  "name": "Old Web App",
  "short_name": "Old Web App"
}''');

      // 4. Setup macOS files
      final macosConfigsDir = Directory(p.join(tempDir.path, 'macos', 'Runner', 'Configs'));
      await macosConfigsDir.create(recursive: true);
      final appInfo = File(p.join(macosConfigsDir.path, 'AppInfo.xcconfig'));
      await appInfo.writeAsString('''
PRODUCT_NAME = old_macos_app
PRODUCT_BUNDLE_IDENTIFIER = com.old.app
''');

      // 5. Setup Windows files
      final winRunnerDir = Directory(p.join(tempDir.path, 'windows', 'runner'));
      await winRunnerDir.create(recursive: true);
      final winRc = File(p.join(winRunnerDir.path, 'Runner.rc'));
      await winRc.writeAsString('''
            VALUE "FileDescription", "old_win_app"
            VALUE "InternalName", "old_win_app"
            VALUE "ProductName", "old_win_app"
''');
      final winMain = File(p.join(winRunnerDir.path, 'main.cpp'));
      await winMain.writeAsString('''
  if (!window.Create(L"Old App", origin, size)) {
    return EXIT_FAILURE;
  }
''');

      // 6. Setup Linux files
      final linuxDir = Directory(p.join(tempDir.path, 'linux'));
      await linuxDir.create(recursive: true);
      final linuxCc = File(p.join(linuxDir.path, 'my_application.cc'));
      await linuxCc.writeAsString('''
  gtk_header_bar_set_title(GTK_HEADER_BAR(header_bar), "Old App");
  gtk_window_set_title(GTK_WINDOW(window), "Old App");
''');
      final linuxCmake = File(p.join(linuxDir.path, 'CMakeLists.txt'));
      await linuxCmake.writeAsString('''
set(APPLICATION_ID "com.old.app")
''');

      // Run rename generator
      const config = RenameConfig(
        appName: 'New Amazing App',
        packageName: 'com.new.amazing',
      );

      final generator = RenameGenerator(
        config: config,
        projectRoot: tempDir.path,
      );

      final updated = await generator.run();

      expect(
        updated,
        containsAll(['Android', 'iOS', 'Web', 'macOS', 'Windows', 'Linux']),
      );

      // Verify Android updates
      final updatedGradle = await buildGradleKts.readAsString();
      expect(updatedGradle, contains('applicationId = "com.new.amazing"'));
      expect(updatedGradle, contains('namespace = "com.new.amazing"'));

      final updatedManifest = await manifestFile.readAsString();
      expect(updatedManifest, contains('package="com.new.amazing"'));
      expect(updatedManifest, contains('android:label="New Amazing App"'));

      final newKotlinFile = File(
        p.join(
          androidAppDir.path,
          'src',
          'main',
          'kotlin',
          'com',
          'new',
          'amazing',
          'MainActivity.kt',
        ),
      );
      expect(await newKotlinFile.exists(), isTrue);
      final updatedKotlinContent = await newKotlinFile.readAsString();
      expect(updatedKotlinContent, contains('package com.new.amazing'));

      // Verify iOS updates
      final updatedPlist = await infoPlist.readAsString();
      expect(updatedPlist, contains('<string>New Amazing App</string>'));

      final updatedPbx = await pbxproj.readAsString();
      expect(
        updatedPbx,
        contains('PRODUCT_BUNDLE_IDENTIFIER = com.new.amazing;'),
      );
      expect(
        updatedPbx,
        contains('PRODUCT_BUNDLE_IDENTIFIER = com.old.app.RunnerTests;'),
      );

      // Verify Web updates
      final updatedIndex = await webIndex.readAsString();
      expect(updatedIndex, contains('<title>New Amazing App</title>'));
      expect(
        updatedIndex,
        contains(
          '<meta name="apple-mobile-web-app-title" content="New Amazing App">',
        ),
      );

      final updatedManifestJson = await webManifest.readAsString();
      expect(updatedManifestJson, contains('"name": "New Amazing App"'));
      expect(updatedManifestJson, contains('"short_name": "New Amazing App"'));

      // Verify macOS updates
      final updatedAppInfo = await appInfo.readAsString();
      expect(updatedAppInfo, contains('PRODUCT_NAME = New Amazing App'));
      expect(
        updatedAppInfo,
        contains('PRODUCT_BUNDLE_IDENTIFIER = com.new.amazing'),
      );

      // Verify Windows updates
      final updatedRc = await winRc.readAsString();
      expect(updatedRc, contains('VALUE "ProductName", "New Amazing App"'));
      final updatedMain = await winMain.readAsString();
      expect(updatedMain, contains('window.Create(L"New Amazing App",'));

      // Verify Linux updates
      final updatedLinuxCc = await linuxCc.readAsString();
      expect(
        updatedLinuxCc,
        contains('gtk_window_set_title(GTK_WINDOW(window), "New Amazing App");'),
      );
      final updatedCmake = await linuxCmake.readAsString();
      expect(updatedCmake, contains('set(APPLICATION_ID "com.new.amazing")'));
    });
  });

  group('CLI Commands Integration', () {
    test('RenameCommand --init creates rename.yaml', () async {
      final cmd = RenameCommand();
      final runner = CommandRunner<int>('test', 'test')..addCommand(cmd);

      final exitCode = await runner.run(['rename', '--init', '-p', tempDir.path]);
      expect(exitCode, equals(0));

      final createdFile = File(p.join(tempDir.path, 'rename.yaml'));
      expect(await createdFile.exists(), isTrue);
      final content = await createdFile.readAsString();
      expect(content, contains('app_name: "My Awesome App"'));
      expect(content, contains('package_name: "com.example.my_awesome_app"'));
    });

    test('FlavorCommand --init detects rename.yaml, generates flavor.yaml, and deletes rename.yaml', () async {
      final renameFile = File(p.join(tempDir.path, 'rename.yaml'));
      await renameFile.writeAsString('''
android:
  app_name: "Aritra Android"
  package_name: "com.example.aritra_android"
ios:
  app_name: "Aritra iOS"
  bundle_id: "com.example.aritra_ios"
''');

      final cmd = FlavorCommand();
      final runner = CommandRunner<int>('test', 'test')..addCommand(cmd);

      final exitCode = await runner.run(['flavor', '--init', '-p', tempDir.path]);
      expect(exitCode, equals(0));

      // flavor.yaml is generated
      final flavorFile = File(p.join(tempDir.path, 'flavor.yaml'));
      expect(await flavorFile.exists(), isTrue);
      final flavorContent = await flavorFile.readAsString();
      expect(flavorContent, contains('applicationId: "com.example.aritra_android.dev"'));
      expect(flavorContent, contains('appName: "Aritra Android Dev"'));
      expect(flavorContent, contains('bundleId: "com.example.aritra_ios.dev"'));
      expect(flavorContent, contains('appName: "Aritra iOS Dev"'));
      expect(flavorContent, contains('applicationId: "com.example.aritra_android"'));
      expect(flavorContent, contains('appName: "Aritra Android"'));
      expect(flavorContent, contains('bundleId: "com.example.aritra_ios"'));
      expect(flavorContent, contains('appName: "Aritra iOS"'));

      // rename.yaml is deleted!
      expect(await renameFile.exists(), isFalse);

      // Subsequent archkit rename informs user to use flavor.yaml
      final renameCmd = RenameCommand();
      final renameRunner = CommandRunner<int>('test', 'test')..addCommand(renameCmd);
      final renameExitCode = await renameRunner.run(['rename', '-p', tempDir.path]);
      expect(renameExitCode, equals(0));
    });
  });
}
