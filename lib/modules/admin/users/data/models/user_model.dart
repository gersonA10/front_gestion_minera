import '../../domain/entity/user_entity.dart';

class RoleModel extends RoleEntity {
  RoleModel({required super.id, required super.name});

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['role_id'].toString(),
      name: json['name'] ?? '',
    );
  }
}

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.roleId,
    required super.roleName,
    required super.isActive,
    super.identification,
    super.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'].toString(),
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      roleId: json['role_id']?.toString() ?? '',
      roleName: json['rol'] ?? '',
      isActive: _parseBool(json['is_active']),
      identification: json['identification']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toUpperCase() == 'ACTIVO';
    return false;
  }
}