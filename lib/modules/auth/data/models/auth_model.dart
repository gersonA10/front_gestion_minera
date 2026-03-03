import 'dart:convert';
import '../../domain/entity/entity.dart';

LoginResponseModel loginResponseFromJson(String str) =>
    LoginResponseModel.fromJson(json.decode(str));

class LoginResponseModel extends LoginResponseEntity {
  LoginResponseModel({
    required super.success,
    required super.message,
    required super.data,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        success: json["success"],
        message: json["message"],
        data: LoginDataModel.fromJson(json["data"]),
      );
}

class LoginDataModel extends LoginDataEntity {
  LoginDataModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.roleName,
    required super.sessionToken,
  });

  factory LoginDataModel.fromJson(Map<String, dynamic> json) => LoginDataModel(
    id: json["id"],
    fullName: json["full_name"],
    email: json["email"],
    roleName: json["role_name"],
    sessionToken: json["session_token"],
  );
}
