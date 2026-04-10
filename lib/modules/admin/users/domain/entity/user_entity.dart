class RoleEntity {
  final String id;
  final String name;

  RoleEntity({required this.id, required this.name});
}

class UserEntity {
  final String id;
  final String fullName;
  final String email;
  final String roleId;
  final String roleName;
  final bool isActive;
  final String? identification;
  final String? phone;

  UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.roleId,
    required this.roleName,
    required this.isActive,
    this.identification,
    this.phone,
  });
}