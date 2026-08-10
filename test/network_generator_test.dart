import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_archkit/src/cli/generators/network/network_generator.dart';

void main() {
  group('NetworkGenerator Test', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('network_test_');
      final pubspecFile = File(p.join(tempDir.path, 'pubspec.yaml'));
      pubspecFile.writeAsStringSync('''
name: test_app
description: A test Flutter app
dependencies:
  flutter:
    sdk: flutter
''');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('generates network files and updates pubspec.yaml', () async {
      final generator = NetworkGenerator();
      await generator.generate(tempDir.path);

      final apiResponseFile = File(
          p.join(tempDir.path, 'lib', 'core', 'util', 'api_response.dart'));
      expect(apiResponseFile.existsSync(), isTrue);

      final content = apiResponseFile.readAsStringSync();
      expect(content, contains('class ApiResponse<T>'));
      expect(content, contains('class ErrorResponse'));
      expect(content, isNot(contains('showLoader()')));
      expect(content, isNot(contains('hideLoader()')));

      final apiUrlsFile = File(
          p.join(tempDir.path, 'lib', 'core', 'constants', 'api_urls.dart'));
      expect(apiUrlsFile.existsSync(), isTrue);
      expect(apiUrlsFile.readAsStringSync(), contains('class ApiUrls'));
      expect(apiUrlsFile.readAsStringSync(),
          contains('static const String baseUrl'));

      final dioNetworkFile = File(
          p.join(tempDir.path, 'lib', 'core', 'network', 'dio_network.dart'));
      expect(dioNetworkFile.existsSync(), isTrue);
      expect(dioNetworkFile.readAsStringSync(),
          contains('package:test_app/core/util/api_response.dart'));

      final pubspecFile = File(p.join(tempDir.path, 'pubspec.yaml'));
      expect(pubspecFile.readAsStringSync(), contains('dio: ^5.4.3'));
    });
  });
}
