import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:interact/interact.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_archkit/src/cli/generators/gen/gen_generator.dart';

class GenerateCommand extends Command<int> {
  @override
  String get name => 'generate';

  @override
  List<String> get aliases => const ['g', 'gen'];

  @override
  String get description =>
      'Generate domain and data layer API methods for @Archkit annotated presentation handlers';

  final GenGenerator _codeGeneratorService;

  GenerateCommand({GenGenerator? codeGeneratorService})
      : _codeGeneratorService = codeGeneratorService ?? GenGenerator() {
    argParser
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Target feature module path or file (e.g. lib/features/home)',
      )
      ..addFlag(
        'dry-run',
        help: 'Preview generated code without modifying files on disk',
        defaultsTo: false,
      );
  }

  @override
  Future<int> run() async {
    final logger = Logger();

    logger.info('${lightGreen.wrap('✔')} Flutter Archkit @Archkit Code Generator\n');

    String? targetPath = argResults?['path'] as String?;
    if (targetPath == null || targetPath.isEmpty) {
      if (argResults?.rest.isNotEmpty == true) {
        targetPath = argResults!.rest.first;
      }
    }

    if (targetPath == null || targetPath.trim().isEmpty) {
      targetPath = Input(
        prompt: 'Target Feature Directory Path',
        defaultValue: 'lib/features/home',
      ).interact().trim();
    }

    final absolutePath = p.canonicalize(targetPath);
    if (!Directory(absolutePath).existsSync() && !File(absolutePath).existsSync()) {
      logger.err('Target path does not exist: $absolutePath');
      return ExitCode.noInput.code;
    }

    final dryRun = argResults?['dry-run'] as bool? ?? false;

    logger.info('${'Target Path'.padRight(18)}: $absolutePath');
    if (dryRun) {
      logger.info('${'Mode'.padRight(18)}: Dry Run (No files will be modified)');
    }

    final progress = logger.progress(
      dryRun ? 'Analyzing @Archkit annotations...' : 'Generating code for @Archkit annotations...',
    );

    try {
      final results = await _codeGeneratorService.generateFeatureCode(
        targetPath: absolutePath,
        dryRun: dryRun,
      );

      final totalGenerated = results.fold<int>(0, (sum, r) => sum + r.methodsGenerated);
      final modifiedFiles = results.where((r) => r.methodsGenerated > 0).toList();

      progress.complete(
        dryRun
            ? 'Analysis complete! Found $totalGenerated method(s) to generate across ${modifiedFiles.length} file(s).'
            : 'Generated $totalGenerated method(s) across ${modifiedFiles.length} file(s)!',
      );

      if (modifiedFiles.isNotEmpty) {
        logger.info('\nFiles ${dryRun ? 'to be modified' : 'modified'}:');
        for (final res in modifiedFiles) {
          final relPath = p.relative(res.filePath, from: Directory.current.path);
          logger.info('  - $relPath (${res.methodsGenerated} method(s) generated)');
        }
      } else {
        logger.info('\nNo new @Archkit methods found to generate.');
      }

      logger.info('\n${lightGreen.wrap('✔')} Done!');
      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Code generation failed: $e');
      return ExitCode.software.code;
    }
  }
}
