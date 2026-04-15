import '../entity/auth_entity.dart';

abstract class AuthRepository {
  Future<LoginResponseEntity> login(String username, String password);
  Future<void> forcePasswordChange(String tempToken, String newPassword);
}
