import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class CodeGeneratorResult {
  final String filePath;
  final int methodsGenerated;
  final bool modified;
  final String? error;

  CodeGeneratorResult({
    required this.filePath,
    required this.methodsGenerated,
    required this.modified,
    this.error,
  });
}

class ArchkitParam {
  final String name;
  final String type;
  final bool isNamed;

  ArchkitParam({
    required this.name,
    this.type = 'dynamic',
    this.isNamed = false,
  });
}

class ArchkitMetadata {
  final String methodName;
  final String endpoint;
  final String returnType;
  final String httpMethod;
  final List<ArchkitParam> params;
  final String sourceFilePath;

  ArchkitMetadata({
    required this.methodName,
    required this.endpoint,
    required this.returnType,
    required this.httpMethod,
    this.params = const [],
    required this.sourceFilePath,
  });

  bool get hasParams => params.isNotEmpty;

  String get paramSignature {
    if (params.isEmpty) return '';
    final positional =
        params.where((p) => !p.isNamed).map((p) => '${p.type} ${p.name}').toList();
    final named = params
        .where((p) => p.isNamed)
        .map((p) => 'required ${p.type} ${p.name}')
        .toList();

    if (positional.isNotEmpty && named.isNotEmpty) {
      return '${positional.join(', ')}, {${named.join(', ')}}';
    } else if (named.isNotEmpty) {
      return '{${named.join(', ')}}';
    } else {
      return positional.join(', ');
    }
  }

  String get paramArguments {
    if (params.isEmpty) return '';
    final positional =
        params.where((p) => !p.isNamed).map((p) => p.name).toList();
    final named =
        params.where((p) => p.isNamed).map((p) => '${p.name}: ${p.name}').toList();

    if (positional.isNotEmpty && named.isNotEmpty) {
      return '${positional.join(', ')}, ${named.join(', ')}';
    } else if (named.isNotEmpty) {
      return named.join(', ');
    } else {
      return positional.join(', ');
    }
  }
}

class FeatureCodeGeneratorService {
  /// Scans presentation layer files under [targetPath] for methods annotated with `@Archkit`.
  /// Generates the corresponding cascading methods in Domain (UseCase, Repository) and Data (RepositoryImpl, RemoteDataSource, RemoteDataSourceImpl).
  Future<List<CodeGeneratorResult>> generateFeatureCode({
    required String targetPath,
    bool dryRun = false,
  }) async {
    final results = <CodeGeneratorResult>[];

    final featureDir = Directory(targetPath);
    if (!featureDir.existsSync() && !File(targetPath).existsSync()) {
      throw FileSystemException('Target path does not exist', targetPath);
    }

    final String actualFeatureDir = File(targetPath).existsSync()
        ? File(targetPath).parent.path
        : targetPath;

    final packageName = _detectPackageName(actualFeatureDir);

    final presentationDir = Directory(p.join(actualFeatureDir, 'presentation'));
    if (!presentationDir.existsSync()) {
      return results;
    }

    final presentationFiles = presentationDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();

    final methodsToGenerate = <String, ArchkitMetadata>{};

    for (final file in presentationFiles) {
      final content = file.readAsStringSync();
      final lines = content.split('\n');

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.contains('@Archkit') || line.contains('@archkit')) {
          // Extract metadata parameters from @Archkit(...)
          final endpointMatch =
              RegExp(r'''endpoint\s*:\s*['"]([^'"]+)['"]''').firstMatch(line);
          final returnTypeMatch =
              RegExp(r'''returnType\s*:\s*['"]?([^,'"\s\)]+)['"]?''').firstMatch(line);
          final httpMethodMatch =
              RegExp(r'''method\s*:\s*['"]([^'"]+)['"]''').firstMatch(line);

          final customEndpoint = endpointMatch?.group(1);
          final customReturnType = returnTypeMatch?.group(1) ?? 'String';
          final customHttpMethod =
              (httpMethodMatch?.group(1) ?? 'GET').toUpperCase();

          // Look at next non-annotation line for method signature
          int nextIdx = i + 1;
          while (
              nextIdx < lines.length && lines[nextIdx].trim().startsWith('@')) {
            nextIdx++;
          }
          if (nextIdx < lines.length) {
            final methodLine = lines[nextIdx].trim();
            final methodMatch =
                RegExp(r'\b([a-zA-Z_]\w*)\s*\(').firstMatch(methodLine);
            if (methodMatch != null) {
              final rawName = methodMatch.group(1)!;

              String targetMethodName = _cleanMethodName(rawName);
              final extractedParams = <ArchkitParam>[];

              for (int bodyIdx = nextIdx;
                  bodyIdx < lines.length && bodyIdx < nextIdx + 25;
                  bodyIdx++) {
                final bodyLine = lines[bodyIdx];
                final callMatch = RegExp(
                        r'(?:useCase|[a-zA-Z_]\w*[uU]se[cC]ase)\.([a-zA-Z_]\w*)\s*\(([^)]*)\)')
                    .firstMatch(bodyLine);
                if (callMatch != null) {
                  final calledName = callMatch.group(1)!;
                  if (calledName != 'call') {
                    targetMethodName = calledName;
                  }

                  final rawArgs = callMatch.group(2)?.trim() ?? '';
                  if (rawArgs.isNotEmpty) {
                    final argParts = rawArgs.split(',');
                    for (final argPart in argParts) {
                      var trimmed = argPart.trim();
                      if (trimmed.isEmpty) continue;
                      String paramName;
                      bool isNamed = false;
                      if (trimmed.contains(':')) {
                        paramName = trimmed.split(':').first.trim();
                        isNamed = true;
                      } else if (trimmed.contains('.')) {
                        paramName = trimmed.split('.').last.trim();
                      } else {
                        paramName = trimmed;
                      }
                      paramName =
                          paramName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
                      if (paramName.isNotEmpty) {
                        final paramType =
                            (paramName.toLowerCase().endsWith('id') ||
                                    paramName.toLowerCase() == 'id'
                                ? 'String'
                                : 'dynamic');
                        extractedParams.add(
                          ArchkitParam(
                            name: paramName,
                            type: paramType,
                            isNamed: isNamed,
                          ),
                        );
                      }
                    }
                  }
                  break;
                }
              }

              final endpoint = customEndpoint ?? '/$targetMethodName';

              methodsToGenerate[targetMethodName] = ArchkitMetadata(
                methodName: targetMethodName,
                endpoint: endpoint,
                returnType: customReturnType,
                httpMethod: customHttpMethod,
                params: extractedParams,
                sourceFilePath: file.path,
              );
            }
          }
        }
      }
    }

    if (methodsToGenerate.isEmpty) {
      return results;
    }

    final featureName = p.basename(actualFeatureDir).toLowerCase();

    final usecaseFile = _findFile(actualFeatureDir, ['domain', 'usecases'],
        '${featureName}_usecase.dart');
    final repoFile = _findFile(actualFeatureDir, ['domain', 'repositories'],
        '${featureName}_repository.dart');
    final repoImplFile = _findFile(actualFeatureDir, ['data', 'repositories'],
        '${featureName}_repository_impl.dart');
    final dsFile = _findFile(actualFeatureDir, ['data', 'data_sources'],
        '${featureName}_remote_datasource.dart');
    final dsImplFile = _findFile(actualFeatureDir, ['data', 'data_sources'],
        '${featureName}_remote_datasource_impl.dart');

    for (final meta in methodsToGenerate.values) {
      if (usecaseFile != null && usecaseFile.existsSync()) {
        final res = _generateInUseCase(usecaseFile, meta, packageName, dryRun);
        results.add(res);
      }
      if (repoFile != null && repoFile.existsSync()) {
        final res = _generateInRepository(repoFile, meta, packageName, dryRun);
        results.add(res);
      }
      if (repoImplFile != null && repoImplFile.existsSync()) {
        final res =
            _generateInRepositoryImpl(repoImplFile, meta, packageName, dryRun);
        results.add(res);
      }
      if (dsFile != null && dsFile.existsSync()) {
        final res =
            _generateInRemoteDataSource(dsFile, meta, packageName, dryRun);
        results.add(res);
      }
      if (dsImplFile != null && dsImplFile.existsSync()) {
        final res = _generateInRemoteDataSourceImpl(
            dsImplFile, meta, packageName, dryRun);
        results.add(res);
      }
    }

    return results;
  }

  String _cleanMethodName(String rawName) {
    var name = rawName;
    if (name.startsWith('_on')) {
      name = name.substring(3);
    } else if (name.startsWith('_')) {
      name = name.substring(1);
    }

    if (name.endsWith('Event')) {
      name = name.substring(0, name.length - 5);
    }

    if (name.isEmpty) return 'getData';
    return name[0].toLowerCase() + name.substring(1);
  }

  String? _detectPackageName(String dirPath) {
    var current = Directory(dirPath);
    while (current.path != current.parent.path) {
      final pubspec = File(p.join(current.path, 'pubspec.yaml'));
      if (pubspec.existsSync()) {
        try {
          final yaml = loadYaml(pubspec.readAsStringSync());
          if (yaml is Map && yaml.containsKey('name')) {
            return yaml['name'] as String?;
          }
        } catch (_) {}
      }
      current = current.parent;
    }
    return null;
  }

  File? _findFile(String baseDir, List<String> subdirs, String fileName) {
    final path = p.joinAll([baseDir, ...subdirs, fileName]);
    final file = File(path);
    if (file.existsSync()) return file;

    final targetDir = Directory(p.joinAll([baseDir, ...subdirs]));
    if (targetDir.existsSync()) {
      for (final entity in targetDir.listSync()) {
        if (entity is File &&
            p.basename(entity.path).toLowerCase() == fileName.toLowerCase()) {
          return entity;
        }
      }
    }
    return null;
  }

  CodeGeneratorResult _generateInUseCase(
      File file, ArchkitMetadata meta, String? packageName, bool dryRun) {
    var content = file.readAsStringSync();
    if (content.contains('${meta.methodName}(')) {
      return CodeGeneratorResult(
          filePath: file.path, methodsGenerated: 0, modified: false);
    }

    final code = '''

  Future<ApiResponse<${meta.returnType}>> ${meta.methodName}(${meta.paramSignature}) async {
    return await repository.${meta.methodName}(${meta.paramArguments});
  }
''';

    content = _insertBeforeLastBrace(content, code);
    content = _ensureApiResponseImport(content, packageName);
    content = _ensureReturnTypeImport(content, meta, packageName);

    if (!dryRun) {
      file.writeAsStringSync(content);
    }
    return CodeGeneratorResult(
        filePath: file.path, methodsGenerated: 1, modified: true);
  }

  CodeGeneratorResult _generateInRepository(
      File file, ArchkitMetadata meta, String? packageName, bool dryRun) {
    var content = file.readAsStringSync();
    if (content.contains('${meta.methodName}(')) {
      return CodeGeneratorResult(
          filePath: file.path, methodsGenerated: 0, modified: false);
    }

    final code = '''
  Future<ApiResponse<${meta.returnType}>> ${meta.methodName}(${meta.paramSignature});
''';

    content = _insertBeforeLastBrace(content, code);
    content = _ensureApiResponseImport(content, packageName);
    content = _ensureReturnTypeImport(content, meta, packageName);

    if (!dryRun) {
      file.writeAsStringSync(content);
    }
    return CodeGeneratorResult(
        filePath: file.path, methodsGenerated: 1, modified: true);
  }

  CodeGeneratorResult _generateInRepositoryImpl(
      File file, ArchkitMetadata meta, String? packageName, bool dryRun) {
    var content = file.readAsStringSync();
    if (content.contains('${meta.methodName}(')) {
      return CodeGeneratorResult(
          filePath: file.path, methodsGenerated: 0, modified: false);
    }

    final code = '''

  @override
  Future<ApiResponse<${meta.returnType}>> ${meta.methodName}(${meta.paramSignature}) async {
    return await remoteDataSource.${meta.methodName}(${meta.paramArguments});
  }
''';

    content = _insertBeforeLastBrace(content, code);
    content = _ensureApiResponseImport(content, packageName);
    content = _ensureReturnTypeImport(content, meta, packageName);

    if (!dryRun) {
      file.writeAsStringSync(content);
    }
    return CodeGeneratorResult(
        filePath: file.path, methodsGenerated: 1, modified: true);
  }

  CodeGeneratorResult _generateInRemoteDataSource(
      File file, ArchkitMetadata meta, String? packageName, bool dryRun) {
    var content = file.readAsStringSync();
    if (content.contains('${meta.methodName}(')) {
      return CodeGeneratorResult(
          filePath: file.path, methodsGenerated: 0, modified: false);
    }

    final code = '''
  Future<ApiResponse<${meta.returnType}>> ${meta.methodName}(${meta.paramSignature});
''';

    content = _insertBeforeLastBrace(content, code);
    content = _ensureApiResponseImport(content, packageName);
    content = _ensureReturnTypeImport(content, meta, packageName);

    if (!dryRun) {
      file.writeAsStringSync(content);
    }
    return CodeGeneratorResult(
        filePath: file.path, methodsGenerated: 1, modified: true);
  }

  CodeGeneratorResult _generateInRemoteDataSourceImpl(
      File file, ArchkitMetadata meta, String? packageName, bool dryRun) {
    var content = file.readAsStringSync();
    if (content.contains('${meta.methodName}(')) {
      return CodeGeneratorResult(
          filePath: file.path, methodsGenerated: 0, modified: false);
    }

    final httpMethodCall = meta.httpMethod.toLowerCase();

    var endpointStr = meta.endpoint;
    bool hasPathTemplate = false;
    for (final p in meta.params) {
      if (endpointStr.contains('{${p.name}}') ||
          endpointStr.contains(':${p.name}')) {
        hasPathTemplate = true;
        endpointStr = endpointStr
            .replaceAll('{${p.name}}', '\$${p.name}')
            .replaceAll(':${p.name}', '\$${p.name}');
      }
    }

    final converterStr = meta.returnType == 'String'
        ? '(response) => response.toString()'
        : (meta.returnType == 'dynamic'
            ? '(response) => response'
            : '(response) => ${meta.returnType}.fromJson(response)');

    String apiCallStr;
    if (meta.params.isEmpty) {
      apiCallStr =
          "api.$httpMethodCall(endpoint: '$endpointStr', converter: $converterStr)";
    } else if (httpMethodCall == 'post' ||
        httpMethodCall == 'put' ||
        httpMethodCall == 'patch') {
      if (meta.params.length == 1) {
        apiCallStr =
            "api.$httpMethodCall(endpoint: '$endpointStr', data: ${meta.params.first.name}, converter: $converterStr)";
      } else {
        final dataMap =
            "{${meta.params.map((p) => "'${p.name}': ${p.name}").join(', ')}}";
        apiCallStr =
            "api.$httpMethodCall(endpoint: '$endpointStr', data: $dataMap, converter: $converterStr)";
      }
    } else {
      // GET or DELETE
      if (hasPathTemplate) {
        apiCallStr =
            "api.$httpMethodCall(endpoint: '$endpointStr', converter: $converterStr)";
      } else {
        final queryMap =
            "{${meta.params.map((p) => "'${p.name}': ${p.name}").join(', ')}}";
        apiCallStr =
            "api.$httpMethodCall(endpoint: '$endpointStr', queryParams: $queryMap, converter: $converterStr)";
      }
    }

    final code = '''

  @override
  Future<ApiResponse<${meta.returnType}>> ${meta.methodName}(${meta.paramSignature}) async {
    return $apiCallStr;
  }
''';

    content = _insertBeforeLastBrace(content, code);
    content = _ensureApiResponseImport(content, packageName);
    content = _ensureReturnTypeImport(content, meta, packageName);

    if (!dryRun) {
      file.writeAsStringSync(content);
    }
    return CodeGeneratorResult(
        filePath: file.path, methodsGenerated: 1, modified: true);
  }

  String _insertBeforeLastBrace(String content, String code) {
    final lastBrace = content.lastIndexOf('}');
    if (lastBrace != -1) {
      return content.substring(0, lastBrace) +
          code +
          content.substring(lastBrace);
    }
    return content + code;
  }

  String _ensureApiResponseImport(String content, String? packageName) {
    if (content.contains('api_response.dart')) return content;
    final importStr = packageName != null
        ? "import 'package:$packageName/core/util/api_response.dart';\n"
        : "import '../../core/util/api_response.dart';\n";

    return importStr + content;
  }

  String _ensureReturnTypeImport(
      String content, ArchkitMetadata meta, String? packageName) {
    final stdTypes = [
      'String',
      'int',
      'double',
      'num',
      'bool',
      'dynamic',
      'void',
      'List',
      'Map'
    ];
    final cleanType = meta.returnType.replaceAll(RegExp(r'[<>]'), '').trim();
    if (stdTypes.contains(cleanType)) return content;

    String importStr;
    final normalizedSource = meta.sourceFilePath.replaceAll('\\', '/');
    final libIdx = normalizedSource.indexOf('/lib/');
    if (libIdx != -1 && packageName != null) {
      final relLibPath = normalizedSource.substring(libIdx + 5);
      importStr = "import 'package:$packageName/$relLibPath';\n";
    } else {
      importStr = "import '${meta.sourceFilePath}';\n";
    }

    if (content.contains(importStr)) return content;
    return importStr + content;
  }
}
