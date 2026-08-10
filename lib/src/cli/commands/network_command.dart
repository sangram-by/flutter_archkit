import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_archkit/src/cli/generators/network/network_generator.dart';

class NetworkCommand extends Command<int> {
  @override
  String get name => 'network';

  @override
  List<String> get aliases => const ['n', 'net'];

  @override
  String get description =>
      'Generate Dio network client and ApiResponse utility module';

  final NetworkGenerator _networkGenerator;

  NetworkCommand({NetworkGenerator? networkGenerator})
      : _networkGenerator = networkGenerator ?? NetworkGenerator() {
    argParser
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Target project path (defaults to current directory)',
      )
      ..addFlag(
        'override',
        help: 'Overwrite existing network files if present',
        defaultsTo: true,
      );
  }

  @override
  Future<int> run() async {
    final logger = Logger();

    logger.info('${lightGreen.wrap('✔')} Flutter Archkit Network Generator\n');

    final targetPath = argResults?['path'] as String? ?? Directory.current.path;
    final projectPath = p.canonicalize(targetPath);
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));

    if (!pubspecFile.existsSync()) {
      logger.err(
        'No pubspec.yaml found at $projectPath. Please run this command inside a Flutter project directory.',
      );
      return ExitCode.noInput.code;
    }

    final shouldOverride = argResults?['override'] as bool? ?? true;

    final progress = logger.progress('Generating network module...');
    try {
      await _networkGenerator.generate(projectPath, override: shouldOverride);
      progress.complete('Network module generated successfully!');

      logger.info('\nFiles generated:');
      logger.info('  - lib/core/constants/api_urls.dart');
      logger.info('  - lib/core/util/api_response.dart');
      logger.info('  - lib/core/util/typedefs.dart');
      logger.info('  - lib/core/network/api_exception.dart');
      logger.info('  - lib/core/network/api_interface.dart');
      logger.info('  - lib/core/network/dio_services.dart');
      logger.info('  - lib/core/network/dio_network.dart');
      logger.info('  - lib/core/network/dio.dart');
      logger.info('  - lib/core/network/interceptors/api_interceptor.dart');
      logger.info('  - lib/core/network/interceptors/logging.dart');
      logger.info('\nDependencies updated:');
      logger.info('  - dio: ^5.4.3 added to pubspec.yaml');

      logger.info(
          '\n${lightGreen.wrap('✔')} Done! Run "flutter pub get" to update dependencies.');
      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to generate network module: $e');
      return ExitCode.software.code;
    }
  }
}
