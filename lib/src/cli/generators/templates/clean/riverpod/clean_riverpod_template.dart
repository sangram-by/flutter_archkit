import 'package:path/path.dart' as p;
import '../../template_generator.dart';

class CleanRiverpodTemplate {
  static void generate(
      TemplateGenerator generator, String basePath, String featureName) {
    final snake = featureName.toLowerCase();
    final pascal = featureName.toPascalCase();

    generator.writeFile(
      p.join(basePath, 'presentation', 'riverpod', '${snake}_provider.dart'),
      '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/${snake}_di.dart';
import '../../domain/usecases/${snake}_usecase.dart';

class ${pascal}Notifier extends StateNotifier<AsyncValue<String>> {
  final ${pascal}UseCase useCase;

  ${pascal}Notifier(this.useCase) : super(const AsyncValue.loading()) {
    loadData();
  }

  Future<void> loadData() async {
    state = const AsyncValue.loading();
    try {
      final result = await useCase();
      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final ${snake}NotifierProvider =
    StateNotifierProvider<${pascal}Notifier, AsyncValue<String>>((ref) {
  final useCase = ${pascal}DI.provide${pascal}UseCase();
  return ${pascal}Notifier(useCase);
});
''',
    );
  }
}
