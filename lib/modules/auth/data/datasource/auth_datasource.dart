import 'package:dio/dio.dart';
import '../../../../core/networking/http_services.dart';
import '../models/model.dart';

class AuthDatasource {
  final ApiClient apiClient;

  AuthDatasource({required this.apiClient});

  Future<LoginResponseModel> login(String email, String password) async {
    final response = await apiClient.post(
      '/api/users/login',
      operationName: 'login',
      data: {"email": email, "password": password},
    );

    return LoginResponseModel.fromJson(response);
  }

  Future<void> forcePasswordChange(String tempToken, String newPassword) async {
    await apiClient.post(
      '/api/users/change-temp-password',
      operationName: 'forcePasswordChange',
      data: {"new_password": newPassword},
      options: Options(headers: {'Authorization': tempToken}),
    );
  }
}