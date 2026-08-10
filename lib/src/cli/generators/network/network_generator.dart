import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter_archkit/src/cli/generators/project/pubspec_modifier.dart';
import 'package:flutter_archkit/src/cli/generators/templates/network/network_templates.dart';

class NetworkGenerator {
  final PubspecModifier _pubspecModifier;

  NetworkGenerator({PubspecModifier? pubspecModifier})
      : _pubspecModifier = pubspecModifier ?? PubspecModifier();

  Future<void> generate(String projectPath, {bool override = true}) async {
    final packageName = _getPackageName(projectPath);

    final utilDir = p.join(projectPath, 'lib', 'core', 'util');
    final constantsDir = p.join(projectPath, 'lib', 'core', 'constants');
    final networkDir = p.join(projectPath, 'lib', 'core', 'network');
    final interceptorsDir = p.join(networkDir, 'interceptors');

    // 0. Write constants files
    _writeFile(
      p.join(constantsDir, 'api_urls.dart'),
      NetworkTemplates.apiUrlsTemplate(),
      override: override,
    );

    // 1. Write util files
    _writeFile(
      p.join(utilDir, 'api_response.dart'),
      NetworkTemplates.apiResponseTemplate(),
      override: override,
    );
    _writeFile(
      p.join(utilDir, 'typedefs.dart'),
      NetworkTemplates.typedefsTemplate(),
      override: override,
    );

    // 2. Write network core files
    _writeFile(
      p.join(networkDir, 'api_exception.dart'),
      NetworkTemplates.apiExceptionTemplate(),
      override: override,
    );
    _writeFile(
      p.join(networkDir, 'api_interface.dart'),
      NetworkTemplates.apiInterfaceTemplate(packageName),
      override: override,
    );
    _writeFile(
      p.join(networkDir, 'dio_services.dart'),
      NetworkTemplates.dioServicesTemplate(packageName),
      override: override,
    );
    _writeFile(
      p.join(networkDir, 'dio_network.dart'),
      NetworkTemplates.dioNetworkTemplate(packageName),
      override: override,
    );
    _writeFile(
      p.join(networkDir, 'dio.dart'),
      NetworkTemplates.dioClientTemplate(packageName),
      override: override,
    );

    // 3. Write interceptors
    _writeFile(
      p.join(interceptorsDir, 'api_interceptor.dart'),
      NetworkTemplates.apiInterceptorTemplate(),
      override: override,
    );
    _writeFile(
      p.join(interceptorsDir, 'logging.dart'),
      NetworkTemplates.loggingInterceptorTemplate(),
      override: override,
    );

    // 4. Update dependencies
    await _pubspecModifier.addNetworkDependencies(projectPath);
  }

  String _getPackageName(String projectPath) {
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (pubspecFile.existsSync()) {
      final content = pubspecFile.readAsStringSync();
      final match = RegExp(r'^name:\s*([a-z0-9_]+)', multiLine: true).firstMatch(content);
      if (match != null && match.group(1) != null) {
        return match.group(1)!;
      }
    }
    return 'my_app';
  }

  void _writeFile(String filePath, String content, {bool override = true}) {
    final file = File(filePath);
    if (!override && file.existsSync()) return;
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
  }
}
