import 'package:front_gestion_minera/core/networking/http_services.dart';
import '../models/user_model.dart';

class UsersDatasource {
  final ApiClient apiClient;

  UsersDatasource({required this.apiClient});

  Future<List<RoleModel>> getRoles() async {
    final response = await apiClient.get(
      '/api/admin/roles',
      operationName: 'getRoles',
    );
    final List<dynamic> data = response['data'] ?? [];
    return data.map((item) => RoleModel.fromJson(item)).toList();
  }

  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null && status != 'Todos') queryParams['status'] = status;

    final response = await apiClient.get(
      '/api/admin/users',
      operationName: 'getUsers',
      queryParameters: queryParams,
    );

    final List<dynamic> data = response['data'] ?? [];
    final Map<String, dynamic> meta = response['meta'] ?? {};

    return {
      'items': data.map((item) => UserModel.fromJson(item)).toList(),
      'has_more_data': meta['has_more_data'] ?? false,
      'total_records': meta['total_records'] ?? 0,
    };
  }

  Future<UserModel> getUserDetail(String userId) async {
    final response = await apiClient.get(
      '/api/admin/users/$userId',
      operationName: 'getUserDetail',
    );
    return UserModel.fromJson(response['data']);
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    await apiClient.post(
      '/api/admin/users',
      operationName: 'createUser',
      data: userData,
    );
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    await apiClient.put(
      '/api/admin/users/$userId',
      operationName: 'updateUser',
      data: userData,
    );
  }
}
