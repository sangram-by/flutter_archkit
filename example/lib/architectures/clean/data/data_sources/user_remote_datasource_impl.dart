import '../../../../core/network/mock_api_client.dart';
import '../models/user_model.dart';
import 'user_remote_datasource.dart';

/// Clean Architecture - Data Layer: Data Source Implementation
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final MockApiClient apiClient;

  UserRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> fetchUser(String userId) async {
    final response = await apiClient.get('/api/v1/user/$userId');
    if (response.isSuccess && response.data != null) {
      return UserModel.fromJson(response.data!);
    } else {
      throw Exception(response.message ?? 'Failed to fetch user data');
    }
  }
}
