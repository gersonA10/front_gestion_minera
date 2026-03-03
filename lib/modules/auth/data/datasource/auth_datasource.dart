import 'package:dio/dio.dart';

import '../../domain/entity/entity.dart';
import '../models/model.dart';

class AuthDatasource {
  final _dio = Dio();
  AuthDatasource();
  Future<LoginResponseEntity> login(String email, String password) async {
    final response = await _dio.post(
      'http://192.168.1.203:3000/api/users/login',
      data: {"email": email, "password": password},
    );
    return LoginResponseModel.fromJson(response.data);
  }
}
