import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../data_sources/user_remote_datasource.dart';

/// Clean Architecture - Data Layer: Concrete Repository Implementation
/// Converts model objects from data source into pure Domain Entities.
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> getUserProfile(String userId) async {
    final userModel = await remoteDataSource.fetchUser(userId);
    return userModel.toEntity();
  }
}
