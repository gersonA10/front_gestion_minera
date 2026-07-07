import '../../domain/entity/user_entity.dart';
import '../../domain/repositories/users_repository.dart';
import '../datasource/users_datasource.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersDatasource datasource;

  UsersRepositoryImpl({required this.datasource});

  @override
  Future<List<RoleEntity>> getRoles() => datasource.getRoles();

  @override
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
  }) {
    return datasource.getUsers(
      page: page,
      limit: limit,
      search: search,
      status: status,
    );
  }

  @override
  Future<UserEntity> getUserDetail(String userId) =>
      datasource.getUserDetail(userId);

  @override
  Future<void> createUser(Map<String, dynamic> userData) =>
      datasource.createUser(userData);

  @override
  Future<void> updateUser(String userId, Map<String, dynamic> userData) =>
      datasource.updateUser(userId, userData);
}
