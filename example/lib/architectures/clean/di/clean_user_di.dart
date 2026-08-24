import '../../../core/network/mock_api_client.dart';
import '../data/data_sources/user_remote_datasource.dart';
import '../data/data_sources/user_remote_datasource_impl.dart';
import '../data/repositories/user_repository_impl.dart';
import '../domain/repositories/user_repository.dart';
import '../domain/usecases/fetch_user_profile_usecase.dart';

/// Clean Architecture - Dependency Injection Container
class CleanUserDI {
  static FetchUserProfileUseCase provideFetchUserProfileUseCase() {
    final apiClient = MockApiClient();
    final UserRemoteDataSource remoteDataSource = UserRemoteDataSourceImpl(apiClient: apiClient);
    final UserRepository repository = UserRepositoryImpl(remoteDataSource: remoteDataSource);
    return FetchUserProfileUseCase(repository: repository);
  }
}
