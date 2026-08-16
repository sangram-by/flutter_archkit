import '../entities/user_entity.dart';

/// Clean Architecture - Domain Layer: Abstract Repository Contract
/// Defines what data the domain needs, without knowing HOW or WHERE it is fetched.
abstract class UserRepository {
  Future<UserEntity> getUserProfile(String userId);
}
