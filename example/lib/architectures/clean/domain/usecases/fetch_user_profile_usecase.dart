import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

/// Clean Architecture - Domain Layer: UseCase
/// Encapsulates a single specific business action or rule.
class FetchUserProfileUseCase {
  final UserRepository repository;

  FetchUserProfileUseCase({required this.repository});

  Future<UserEntity> call(String userId) async {
    return await repository.getUserProfile(userId);
  }
}
