class LoginResponseEntity {
  final bool success;
  final String message;
  final String? reason;
  final LoginDataEntity? data;
  final String? tempToken;

  LoginResponseEntity({
    required this.success,
    required this.message,
    this.reason,
    this.data,
    this.tempToken,
  });
}

class LoginDataEntity {
  final String id;
  final String fullName;
  final String email;
  final String roleName;
  final String sessionToken;

  LoginDataEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.roleName,
    required this.sessionToken,
  });
}
