import 'package:front_gestion_minera/modules/auth/domain/entity/auth_entity.dart';

import '../../domain/repositories/repository.dart';
import '../datasource/auth_datasource.dart';

class AuthRepositoryImpl extends AuthRepository {
  AuthDatasource datasource;
  AuthRepositoryImpl({required this.datasource});

  @override
  Future<LoginResponseEntity> login(String username, String password) async {
    return await datasource.login(username, password);
  }

  @override
  Future<void> forcePasswordChange(String tempToken, String newPassword) async {
    await datasource.forcePasswordChange(tempToken, newPassword);
  }
}
