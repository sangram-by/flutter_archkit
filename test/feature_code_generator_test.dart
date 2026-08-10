import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_archkit/src/services/feature_code_generator_service.dart';
import 'package:flutter_archkit/src/cli/commands/generate_command.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('feature_code_gen_test_');

    final featureDir = Directory(p.join(tempDir.path, 'lib', 'features', 'home'));
    final blocDir = Directory(p.join(featureDir.path, 'presentation', 'bloc'))..createSync(recursive: true);
    final usecaseDir = Directory(p.join(featureDir.path, 'domain', 'usecases'))..createSync(recursive: true);
    final repoDomainDir = Directory(p.join(featureDir.path, 'domain', 'repositories'))..createSync(recursive: true);
    final dsDataDir = Directory(p.join(featureDir.path, 'data', 'data_sources'))..createSync(recursive: true);
    final repoDataDir = Directory(p.join(featureDir.path, 'data', 'repositories'))..createSync(recursive: true);

    File(p.join(blocDir.path, 'home_bloc.dart')).writeAsStringSync('''
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadWeatherEvent>(_onLoadWeatherEvent);
  }

  @Archkit
  Future<void> _onLoadWeatherEvent(
    LoadWeatherEvent event,
    Emitter<HomeState> emit,
  ) async {
    final response = await homeUseCase.call();
  }
}
''');

    File(p.join(usecaseDir.path, 'home_usecase.dart')).writeAsStringSync('''
class HomeUseCase {
  final HomeRepository repository;
  HomeUseCase({required this.repository});
}
''');

    File(p.join(repoDomainDir.path, 'home_repository.dart')).writeAsStringSync('''
abstract class HomeRepository {}
''');

    File(p.join(repoDataDir.path, 'home_repository_impl.dart')).writeAsStringSync('''
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  HomeRepositoryImpl({required this.remoteDataSource});
}
''');

    File(p.join(dsDataDir.path, 'home_remote_datasource.dart')).writeAsStringSync('''
abstract class HomeRemoteDataSource {}
''');

    File(p.join(dsDataDir.path, 'home_remote_datasource_impl.dart')).writeAsStringSync('''
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioNetwork api = DioNetwork();
}
''');
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('FeatureCodeGeneratorService generates cascading domain and data API methods for @Archkit handler', () async {
    final service = FeatureCodeGeneratorService();
    final featurePath = p.join(tempDir.path, 'lib', 'features', 'home');

    final results = await service.generateFeatureCode(targetPath: featurePath);

    final totalGenerated = results.fold<int>(0, (sum, r) => sum + r.methodsGenerated);
    expect(totalGenerated, equals(5));

    final usecaseContent = File(p.join(featurePath, 'domain', 'usecases', 'home_usecase.dart')).readAsStringSync();
    expect(usecaseContent, contains('Future<ApiResponse<String>> loadWeather() async'));
    expect(usecaseContent, contains('return await repository.loadWeather();'));

    final repoContent = File(p.join(featurePath, 'domain', 'repositories', 'home_repository.dart')).readAsStringSync();
    expect(repoContent, contains('Future<ApiResponse<String>> loadWeather();'));

    final repoImplContent = File(p.join(featurePath, 'data', 'repositories', 'home_repository_impl.dart')).readAsStringSync();
    expect(repoImplContent, contains('Future<ApiResponse<String>> loadWeather() async'));
    expect(repoImplContent, contains('return await remoteDataSource.loadWeather();'));

    final dsContent = File(p.join(featurePath, 'data', 'data_sources', 'home_remote_datasource.dart')).readAsStringSync();
    expect(dsContent, contains('Future<ApiResponse<String>> loadWeather();'));

    final dsImplContent = File(p.join(featurePath, 'data', 'data_sources', 'home_remote_datasource_impl.dart')).readAsStringSync();
    expect(dsImplContent, contains('Future<ApiResponse<String>> loadWeather() async'));
    expect(dsImplContent, contains("api.get(endpoint: '/loadWeather'"));
  });

  test('GenerateCommand metadata test', () {
    final command = GenerateCommand();
    expect(command.name, equals('generate'));
    expect(command.aliases, contains('g'));
  });
}
