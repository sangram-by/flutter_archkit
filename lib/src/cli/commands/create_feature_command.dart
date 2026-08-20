import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:interact/interact.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:flutter_archkit/src/models/project_config.dart';
import 'package:flutter_archkit/src/services/metadata_config_service.dart';
import 'package:flutter_archkit/src/cli/generators/templates/clean/clean_template_generator.dart';
import 'package:flutter_archkit/src/cli/generators/templates/mvvm/mvvm_template_generator.dart';
import 'package:flutter_archkit/src/cli/generators/templates/mvc/mvc_template_generator.dart';

import 'package:flutter_archkit/src/cli/generators/project/pubspec_modifier.dart';

class CreateFeatureCommand extends Command<int> {
  @override
  String get name => 'feature';

  @override
  List<String> get aliases => const ['f'];

  @override
  String get description => 'Generate a new feature module';

  final MetadataConfigService _metadataConfigService;
  final PubspecModifier _pubspecModifier;

  CreateFeatureCommand({
    MetadataConfigService? metadataConfigService,
    PubspecModifier? pubspecModifier,
  })  : _metadataConfigService = metadataConfigService ?? MetadataConfigService(),
        _pubspecModifier = pubspecModifier ?? PubspecModifier() {
    argParser
      ..addOption('name', abbr: 'n', help: 'Feature name (e.g. auth, profile)')
      ..addOption('architecture', abbr: 'a', help: 'Architecture (Clean, MVVM, MVC)')
      ..addOption('state-management', abbr: 's', help: 'State management (Bloc, Cubit, Riverpod, Provider, GetX)')
      ..addOption('path', abbr: 'p', help: 'Target project path')
      ..addFlag('di', help: 'Enable Dependency Injection (GetIt + Injectable)', defaultsTo: false);
  }

  @override
  Future<int> run() async {
    final logger = Logger();

    logger.info('${lightGreen.wrap('✔')} Flutter Archkit Feature Generator\n');

    // 1. Feature Name
    String? featureName = argResults?['name'] as String?;
    if (featureName == null || featureName.isEmpty) {
      if (argResults?.rest.isNotEmpty == true) {
        featureName = argResults!.rest.first;
      }
    }

    if (featureName == null || featureName.trim().isEmpty) {
      featureName = Input(
        prompt: 'Feature Name',
        defaultValue: 'auth',
      ).interact().trim();
      if (featureName.isEmpty) {
        featureName = 'auth';
      }
    }

    logger.info('${'Feature Name'.padRight(18)}: $featureName');

    // Attempt to load existing config from .metadata
    final savedConfig = _metadataConfigService.readConfig(Directory.current.path);

    // 2. Architecture
    final archOption = argResults?['architecture'] as String?;
    String architecture;
    final archChoices = const ['Clean', 'MVVM', 'MVC'];
    if (archOption != null &&
        archChoices.map((e) => e.toLowerCase()).contains(archOption.toLowerCase())) {
      architecture = archChoices.firstWhere(
        (e) => e.toLowerCase() == archOption.toLowerCase(),
      );
    } else if (savedConfig != null) {
      architecture = savedConfig.architecture;
      logger.info('${'Architecture'.padRight(18)}: $architecture (from .metadata)');
    } else {
      final archIndex = Select(
        prompt: 'Select Architecture',
        options: archChoices,
        initialIndex: 0,
      ).interact();
      architecture = archChoices[archIndex];
    }

    // 3. State Management
    final smOption = argResults?['state-management'] as String?;
    String stateManagement;
    final smChoices = const ['Bloc', 'Cubit', 'Riverpod', 'Provider', 'GetX'];
    if (smOption != null &&
        smChoices.map((e) => e.toLowerCase()).contains(smOption.toLowerCase())) {
      stateManagement = smChoices.firstWhere(
        (e) => e.toLowerCase() == smOption.toLowerCase(),
      );
    } else if (savedConfig != null) {
      stateManagement = savedConfig.stateManagement;
      logger.info('${'State Management'.padRight(18)}: $stateManagement (from .metadata)');
    } else {
      final smIndex = Select(
        prompt: 'Select State Management',
        options: smChoices,
        initialIndex: 0,
      ).interact();
      stateManagement = smChoices[smIndex];
    }

    // 4. Dependency Injection Prompt
    bool useDi;
    if (argResults?.wasParsed('di') == true) {
      useDi = argResults!['di'] as bool;
    } else {
      useDi = Confirm(
        prompt: 'Include Dependency Injection (GetIt + Injectable)?',
        defaultValue: true,
      ).interact();
    }
    logger.info('${'Dependency Injection'.padRight(18)}: ${useDi ? 'Enabled (GetIt + Injectable)' : 'Disabled'}');

    // Save or update .metadata if missing or explicitly overridden
    _metadataConfigService.writeConfig(
      Directory.current.path,
      architecture: architecture,
      stateManagement: stateManagement,
    );

    final config = ProjectConfig(
      name: featureName,
      architecture: architecture,
      stateManagement: stateManagement,
      organization: 'com.example',
      platforms: const ['android', 'ios'],
      useDi: useDi,
    );

    final projectPath = (argResults?['path'] as String?) ?? Directory.current.path;
    final progress = logger.progress('Generating feature \'$featureName\'...');

    await _pubspecModifier.addDependencies(projectPath, stateManagement);
    if (useDi) {
      await _pubspecModifier.addDIDependencies(projectPath);
    }

    final archLower = architecture.toLowerCase();
    if (archLower == 'clean') {
      await CleanTemplateGenerator().generate(config, projectPath, featureName: featureName);
    } else if (archLower == 'mvvm') {
      await MvvmTemplateGenerator().generate(config, projectPath, featureName: featureName);
    } else if (archLower == 'mvc') {
      await MvcTemplateGenerator().generate(config, projectPath, featureName: featureName);
    } else {
      await CleanTemplateGenerator().generate(config, projectPath, featureName: featureName);
    }

    progress.complete('Feature \'$featureName\' generated successfully!');

    logger.info('\n${lightGreen.wrap('✔')} Done!');
    return ExitCode.success.code;
  }
}

