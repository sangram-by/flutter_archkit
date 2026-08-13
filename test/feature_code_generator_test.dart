import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_archkit/src/cli/generators/gen/gen_generator.dart';
import 'package:flutter_archkit/src/cli/commands/generate_command.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('feature_code_gen_test_');

    final featureDir =
        Directory(p.join(tempDir.path, 'lib', 'features', 'home'));
    final blocDir = Directory(p.join(featureDir.path, 'presentation', 'bloc'))
      ..createSync(recursive: true);
    final usecaseDir = Directory(p.join(featureDir.path, 'domain', 'usecases'))
      ..createSync(recursive: true);
    final repoDomainDir =
        Directory(p.join(featureDir.path, 'domain', 'repositories'))
          ..createSync(recursive: true);
    final dsDataDir = Directory(p.join(featureDir.path, 'data', 'data_sources'))
      ..createSync(recursive: true);
    final repoDataDir =
        Directory(p.join(featureDir.path, 'data', 'repositories'))
          ..createSync(recursive: true);

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

    File(p.join(repoDomainDir.path, 'home_repository.dart'))
        .writeAsStringSync('''
abstract class HomeRepository {}
''');

    File(p.join(repoDataDir.path, 'home_repository_impl.dart'))
        .writeAsStringSync('''
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  HomeRepositoryImpl({required this.remoteDataSource});
}
''');

    File(p.join(dsDataDir.path, 'home_remote_datasource.dart'))
        .writeAsStringSync('''
abstract class HomeRemoteDataSource {}
''');

    File(p.join(dsDataDir.path, 'home_remote_datasource_impl.dart'))
        .writeAsStringSync('''
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

  test(
      'FeatureCodeGeneratorService generates cascading domain and data API methods for @Archkit handler',
      () async {
    final service = FeatureCodeGeneratorService();
    final featurePath = p.join(tempDir.path, 'lib', 'features', 'home');

    final results = await service.generateFeatureCode(targetPath: featurePath);

    final totalGenerated =
        results.fold<int>(0, (sum, r) => sum + r.methodsGenerated);
    expect(totalGenerated, equals(5));

    final usecaseContent =
        File(p.join(featurePath, 'domain', 'usecases', 'home_usecase.dart'))
            .readAsStringSync();
    expect(usecaseContent,
        contains('Future<ApiResponse<String>> loadWeather() async'));
    expect(usecaseContent, contains('return await repository.loadWeather();'));

    final repoContent = File(p.join(
            featurePath, 'domain', 'repositories', 'home_repository.dart'))
        .readAsStringSync();
    expect(repoContent, contains('Future<ApiResponse<String>> loadWeather();'));

    final repoImplContent = File(p.join(
            featurePath, 'data', 'repositories', 'home_repository_impl.dart'))
        .readAsStringSync();
    expect(repoImplContent,
        contains('Future<ApiResponse<String>> loadWeather() async'));
    expect(repoImplContent,
        contains('return await remoteDataSource.loadWeather();'));

    final dsContent = File(p.join(
            featurePath, 'data', 'data_sources', 'home_remote_datasource.dart'))
        .readAsStringSync();
    expect(dsContent, contains('Future<ApiResponse<String>> loadWeather();'));

    final dsImplContent = File(p.join(featurePath, 'data', 'data_sources',
            'home_remote_datasource_impl.dart'))
        .readAsStringSync();
    expect(dsImplContent,
        contains('Future<ApiResponse<String>> loadWeather() async'));
    expect(dsImplContent, contains("api.get(endpoint: '/loadWeather'"));
  });

  test(
      'FeatureCodeGeneratorService automatically detects named and positional parameters and generates custom return type imports',
      () async {
    final service = FeatureCodeGeneratorService();
    final featurePath = p.join(tempDir.path, 'lib', 'features', 'home');

    // Add handlers with named (body: value) and positional (value) calls and returnType: "User"
    final blocFile =
        File(p.join(featurePath, 'presentation', 'bloc', 'home_bloc.dart'));
    blocFile.writeAsStringSync('''
import 'package:flutter_bloc/flutter_bloc.dart';

class User {}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial());

  @Archkit(endpoint: "/loadEvent1", method: "GET", returnType: User)
  Future<void> _onLoadWeatherEvent1(
    LoadHomeDataEvent1 event,
    Emitter<HomeState> emit,
  ) async {
    final value = {"value": 1000};
    final response = await homeUseCase.loadWeatherEvent1(body: value);
  }

  @Archkit(endpoint: "/loadEvent2", method: "POST", returnType: User)
  Future<void> _onLoadWeatherEvent2(
    LoadHomeDataEvent2 event,
    Emitter<HomeState> emit,
  ) async {
    final value = {"value": 2000};
    final response = await homeUseCase.loadWeatherEvent2(value);
  }

  @Archkit(endpoint: "/users/{id}", method: "GET")
  Future<void> _onGetUser(
    GetUserEvent event,
    Emitter<HomeState> emit,
  ) async {
    final response = await homeUseCase.getUser(event.id);
  }
}
''');

    final results = await service.generateFeatureCode(targetPath: featurePath);
    expect(results, isNotEmpty);

    final usecaseContent =
        File(p.join(featurePath, 'domain', 'usecases', 'home_usecase.dart'))
            .readAsStringSync();
    expect(
        usecaseContent,
        contains(
            'Future<ApiResponse<User>> loadWeatherEvent1({required dynamic body}) async'));
    expect(usecaseContent,
        contains('return await repository.loadWeatherEvent1(body: body);'));
    expect(
        usecaseContent,
        contains(
            'Future<ApiResponse<User>> loadWeatherEvent2(dynamic value) async'));
    expect(usecaseContent,
        contains('return await repository.loadWeatherEvent2(value);'));
    expect(usecaseContent,
        contains('Future<ApiResponse<String>> getUser(String id) async'));
    expect(usecaseContent, contains('home_bloc.dart'));

    final dsImplContent = File(p.join(featurePath, 'data', 'data_sources',
            'home_remote_datasource_impl.dart'))
        .readAsStringSync();
    expect(
        dsImplContent,
        contains(
            "api.get(endpoint: '/loadEvent1', queryParams: {'body': body}"));
    expect(dsImplContent,
        contains("api.post(endpoint: '/loadEvent2', data: value"));
    expect(dsImplContent, contains("api.get(endpoint: '/users/\$id'"));
    expect(dsImplContent, contains('home_bloc.dart'));
  });

  test('GenGenerator generates cascading methods for MVVM services', () async {
    final service = GenGenerator();
    final mvvmDir = Directory(p.join(tempDir.path, 'lib', 'mvvm_feature'));
    final vmFile =
        File(p.join(mvvmDir.path, 'viewmodels', 'home_viewmodel.dart'));
    vmFile.parent.createSync(recursive: true);
    vmFile.writeAsStringSync('''
import 'package:flutter_archkit/flutter_archkit.dart';

class User {}

class HomeViewModel {
  @Archkit(endpoint: "/loadProfile", method: "GET", returnType: User)
  Future<void> fetchProfile(String userId) async {
    final res = await service.fetchProfile(userId);
  }
}
''');

    final serviceFile =
        File(p.join(mvvmDir.path, 'services', 'home_service.dart'));
    serviceFile.parent.createSync(recursive: true);
    serviceFile.writeAsStringSync('''
class HomeService {}
''');

    final results = await service.generateFeatureCode(targetPath: mvvmDir.path);
    expect(results, isNotEmpty);

    final serviceContent = serviceFile.readAsStringSync();
    expect(
        serviceContent,
        contains(
            'Future<ApiResponse<User>> fetchProfile(String userId) async'));
    expect(serviceContent, contains("api.get(endpoint: '/loadProfile'"));
  });

  test('GenGenerator generates cascading methods for MVC providers', () async {
    final service = GenGenerator();
    final mvcDir = Directory(p.join(tempDir.path, 'lib', 'mvc_feature'));
    final controllerFile =
        File(p.join(mvcDir.path, 'controllers', 'home_controller.dart'));
    controllerFile.parent.createSync(recursive: true);
    controllerFile.writeAsStringSync('''
import 'package:flutter_archkit/flutter_archkit.dart';

class User {}

class HomeController {
  @Archkit(endpoint: "/updateData", method: "POST", returnType: User)
  Future<void> updateData(dynamic payload) async {
    final res = await provider.updateData(payload);
  }
}
''');

    final providerFile =
        File(p.join(mvcDir.path, 'providers', 'home_provider.dart'));
    providerFile.parent.createSync(recursive: true);
    providerFile.writeAsStringSync('''
class HomeProvider {}
''');

    final results = await service.generateFeatureCode(targetPath: mvcDir.path);
    expect(results, isNotEmpty);

    final providerContent = providerFile.readAsStringSync();
    expect(
        providerContent,
        contains(
            'Future<ApiResponse<User>> updateData(dynamic payload) async'));
    expect(providerContent, contains("api.post(endpoint: '/updateData'"));
  });

  test('GenerateCommand metadata test', () {
    final command = GenerateCommand();
    expect(command.name, equals('generate'));
    expect(command.aliases, contains('g'));
  });
}
