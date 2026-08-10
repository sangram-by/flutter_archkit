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

class ArchkitMetadata {
  final String methodName;
  final String endpoint;
  final String returnType;
  final String httpMethod;

  ArchkitMetadata({
    required this.methodName,
    required this.endpoint,
    required this.returnType,
    required this.httpMethod,
  });
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
          final endpointMatch = RegExp(r'''endpoint\s*:\s*['"]([^'"]+)['"]''').firstMatch(line);
          final returnTypeMatch = RegExp(r'''returnType\s*:\s*['"]([^'"]+)['"]''').firstMatch(line);
          final httpMethodMatch = RegExp(r'''method\s*:\s*['"]([^'"]+)['"]''').firstMatch(line);

          final customEndpoint = endpointMatch?.group(1);
          final customReturnType = returnTypeMatch?.group(1) ?? 'String';
          final customHttpMethod = (httpMethodMatch?.group(1) ?? 'GET').toUpperCase();

          // Look at next non-annotation line for method signature
          int nextIdx = i + 1;
          while (nextIdx < lines.length && lines[nextIdx].trim().startsWith('@')) {
            nextIdx++;
          }
          if (nextIdx < lines.length) {
            final methodLine = lines[nextIdx].trim();
            final methodMatch = RegExp(r'\b([a-zA-Z_]\w*)\s*\(').firstMatch(methodLine);
            if (methodMatch != null) {
              final rawName = methodMatch.group(1)!;

              String targetMethodName = _cleanMethodName(rawName);
              for (int bodyIdx = nextIdx; bodyIdx < lines.length && bodyIdx < nextIdx + 20; bodyIdx++) {
                final bodyLine = lines[bodyIdx];
                final callMatch = RegExp(r'useCase\.([a-zA-Z_]\w*)\s*\(').firstMatch(bodyLine);
                if (callMatch != null) {
                  final calledName = callMatch.group(1)!;
                  if (calledName != 'call') {
                    targetMethodName = calledName;
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

    final usecaseFile = _findFile(actualFeatureDir, ['domain', 'usecases'], '${featureName}_usecase.dart');
    final repoFile = _findFile(actualFeatureDir, ['domain', 'repositories'], '${featureName}_repository.dart');
    final repoImplFile = _findFile(actualFeatureDir, ['data', 'repositories'], '${featureName}_repository_impl.dart');
    final dsFile = _findFile(actualFeatureDir, ['data', 'data_sources'], '${featureName}_remote_datasource.dart');
    final dsImplFile = _findFile(actualFeatureDir, ['data', 'data_sources'], '${featureName}_remote_datasource_impl.dart');

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
        final res = _generateInRepositoryImpl(repoImplFile, meta, packageName, dryRun);
        results.add(res);
      }
      if (dsFile != null && dsFile.existsSync()) {
        final res = _generateInRemoteDataSource(dsFile, meta, packageName, dryRun);
        results.add(res);
      }
      if (dsImplFile != null && dsImplFile.existsSync()) {
        final res = _generateInRemoteDataSourceImpl(dsImplFile, meta, packageName, dryRun);
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
        if (entity is File && p.basename(entity.path).toLowerCase() == fileName.toLowerCase()) {
          return entity;
        }
      }
    }
    return null;
  }

  CodeGeneratorResult _generateInUseCase(File file, ArchkitMetadata meta, String? packageName, bool dryRun) {
    var content = file.readAsStringSync();
    if (content.contains('${meta.methodName}(')) {
      return CodeGeneratorResult(filePath: file.path, methodsGenerated: 0, modified: false);
    }

    final code = '''

  Future<ApiResponse<${meta.returnType}>> ${meta.methodName}() async {
    return await repository.${meta.methodName}();
  }
''';

    content = _insertBeforeLastBrace(content, code);
    content = _ensureApiResponseImport(content, packageName);

    if (!dryRun) {
      file.writeAsStringSync(content);
    }
    return CodeGeneratorResult(filePath: file.path, methodsGenerated: 1, modified: true);
  }

  CodeGeneratorResult _generateInRepository(File file, ArchkitMetadata meta, String? packageName, bool dryRun) {
    var content = file.readAsStringSync();
    if (content.contains('${meta.methodName}(')) {
      return CodeGeneratorResult(filePath: file.path, methodsGenerated: 0, modified: false);
    }

    final code = '''
  Future<ApiResponse<${meta.returnType}>> ${meta.methodName}();
''';

    content = _insertBeforeLastBrace(content, code);
    content = _ensureApiResponseImport(content, packageName);

    if (!dryRun) {
      file.writeAsStringSync(content);
    }
    return CodeGeneratorResult(filePath: file.path, methodsGenerated: 1, modified: true);
  }

  CodeGeneratorResult _generateInRepositoryImpl(File file, ArchkitMetadata meta, String? packageName, bool dryRun) {
    var content = file.readAsStringSync();
    if (content.contains('${meta.methodName}(')) {
      return CodeGeneratorResult(filePath: file.path, methodsGenerated: 0, modified: false);
    }

    final code = '''

  @override
  Future<ApiResponse<${meta.returnType}>> ${meta.methodName}() async {
    return await remoteDataSource.${meta.methodName}();
  }
''';

    content = _insertBeforeLastBrace(content, code);
    content = _ensureApiResponseImport(content, packageName);

    if (!dryRun) {
      file.writeAsStringSync(content);
    }
    return CodeGeneratorResult(filePath: file.path, methodsGenerated: 1, modified: true);
  }

  CodeGeneratorResult _generateInRemoteDataSource(File file, ArchkitMetadata meta, String? packageName, bool dryRun) {
    var content = file.readAsStringSync();
    if (content.contains('${meta.methodName}(')) {
      return CodeGeneratorResult(filePath: file.path, methodsGenerated: 0, modified: false);
    }

    final code = '''
  Future<ApiResponse<${meta.returnType}>> ${meta.methodName}();
''';

    content = _insertBeforeLastBrace(content, code);
    content = _ensureApiResponseImport(content, packageName);

    if (!dryRun) {
      file.writeAsStringSync(content);
    }
    return CodeGeneratorResult(filePath: file.path, methodsGenerated: 1, modified: true);
  }

  CodeGeneratorResult _generateInRemoteDataSourceImpl(File file, ArchkitMetadata meta, String? packageName, bool dryRun) {
    var content = file.readAsStringSync();
    if (content.contains('${meta.methodName}(')) {
      return CodeGeneratorResult(filePath: file.path, methodsGenerated: 0, modified: false);
    }

    final httpMethodCall = meta.httpMethod.toLowerCase();

    final code = '''

  @override
  Future<ApiResponse<${meta.returnType}>> ${meta.methodName}() async {
    return api.$httpMethodCall(endpoint: '${meta.endpoint}', converter: (response) => response.toString());
  }
''';

    content = _insertBeforeLastBrace(content, code);
    content = _ensureApiResponseImport(content, packageName);

    if (!dryRun) {
      file.writeAsStringSync(content);
    }
    return CodeGeneratorResult(filePath: file.path, methodsGenerated: 1, modified: true);
  }

  String _insertBeforeLastBrace(String content, String code) {
    final lastBrace = content.lastIndexOf('}');
    if (lastBrace != -1) {
      return content.substring(0, lastBrace) + code + content.substring(lastBrace);
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
}
