import '../models/user_model.dart';

/// Clean Architecture - Data Layer: Data Source Interface
abstract class UserRemoteDataSource {
  Future<UserModel> fetchUser(String userId);
}
