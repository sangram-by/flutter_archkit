import 'dart:io';
import 'package:yaml/yaml.dart';
import 'flavor_config.dart';
import 'flavor_exceptions.dart';

/// Loads flavor definitions from a yaml file (default: flavor.yaml at the
/// project root) and converts them into a `List<FlavorConfig>`.
///
/// Expected file shape:
/// ```yaml
/// flavors:
///   dev:
///     app:
///       name: "MyApp Dev"
///       baseUrl: "https://dev.api.example.com"
///     android:
///       applicationId: "com.example.myapp.dev"
///     ios:
///       bundleId: "com.example.myapp.dev"
/// ```
class FlavorYamlLoader {
  final String projectRoot;
  final String fileName;

  FlavorYamlLoader({this.projectRoot = '.', this.fileName = 'flavor.yaml'});

  String get _path => '$projectRoot/$fileName';

  /// Reads and parses the yaml file.
  /// Throws [FlavorYamlNotFoundException], [FlavorYamlEmptyException],
  /// or [FlavorYamlParseException] on failure.
  Future<List<FlavorConfig>> load() async {
    var file = File(_path);

    if (!await file.exists()) {
      if (fileName == 'flavor.yaml') {
        final ymlFile = File('$projectRoot/flavor.yml');
        if (await ymlFile.exists()) {
          file = ymlFile;
        } else {
          throw FlavorYamlNotFoundException(_path);
        }
      } else {
        throw FlavorYamlNotFoundException(_path);
      }
    }

    final raw = await file.readAsString();

    late final YamlDocument doc;
    try {
      doc = loadYamlDocument(raw);
    } on YamlException catch (e) {
      throw FlavorYamlParseException('invalid YAML syntax in "$_path" — $e');
    }

    final root = doc.contents.value;
    if (root is! YamlMap || !root.containsKey('flavors')) {
      throw FlavorYamlEmptyException(_path);
    }

    final flavorsNode = root['flavors'];
    if (flavorsNode is! YamlMap || flavorsNode.isEmpty) {
      throw FlavorYamlEmptyException(_path);
    }

    final result = <FlavorConfig>[];

    for (final entry in flavorsNode.entries) {
      final name = entry.key.toString();
      final value = entry.value;

      if (value is! YamlMap) {
        throw FlavorYamlParseException(
          'flavor "$name" must be a map containing app, android, and ios sections',
        );
      }

      final appNode = value['app'];
      final androidNode = value['android'];
      final iosNode = value['ios'];

      if (appNode is! YamlMap) {
        throw FlavorYamlParseException(
          'flavor "$name" is missing required "app" section with "name" and "baseUrl"',
        );
      }

      if (androidNode is! YamlMap) {
        throw FlavorYamlParseException(
          'flavor "$name" is missing required "android" section with "applicationId"',
        );
      }

      if (iosNode is! YamlMap) {
        throw FlavorYamlParseException(
          'flavor "$name" is missing required "ios" section with "bundleId"',
        );
      }

      final appName = appNode['name'];
      final baseUrl = appNode['baseUrl'];
      final applicationId = androidNode['applicationId'];
      final bundleId = iosNode['bundleId'];

      if (appName == null || appName is! String || appName.trim().isEmpty) {
        throw FlavorYamlParseException(
          'flavor "$name.app" is missing a non-empty "name" string',
        );
      }
      if (baseUrl == null || baseUrl is! String || baseUrl.trim().isEmpty) {
        throw FlavorYamlParseException(
          'flavor "$name.app" is missing a non-empty "baseUrl" string',
        );
      }
      if (applicationId == null ||
          applicationId is! String ||
          applicationId.trim().isEmpty) {
        throw FlavorYamlParseException(
          'flavor "$name.android" is missing a non-empty "applicationId" string',
        );
      }
      if (bundleId == null || bundleId is! String || bundleId.trim().isEmpty) {
        throw FlavorYamlParseException(
          'flavor "$name.ios" is missing a non-empty "bundleId" string',
        );
      }

      final androidAppName = (androidNode['appName'] ?? androidNode['name'])?.toString().trim();
      final iosAppName = (iosNode['appName'] ?? iosNode['name'])?.toString().trim();

      result.add(
        FlavorConfig(
          name: name,
          appName: appName.trim(),
          androidAppName: (androidAppName != null && androidAppName.isNotEmpty)
              ? androidAppName
              : null,
          iosAppName: (iosAppName != null && iosAppName.isNotEmpty)
              ? iosAppName
              : null,
          applicationId: applicationId.trim(),
          bundleId: bundleId.trim(),
          baseUrl: baseUrl.trim(),
        ),
      );
    }

    return result;
  }
}
