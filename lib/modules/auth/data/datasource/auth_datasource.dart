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
}