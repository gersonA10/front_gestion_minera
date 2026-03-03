import '../entity/auth_entity.dart';

abstract class AuthRepository {
  Future<LoginResponseEntity> login(String username, String password);
}
