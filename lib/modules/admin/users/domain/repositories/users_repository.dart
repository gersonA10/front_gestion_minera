import '../entity/user_entity.dart';

abstract class UsersRepository {
  Future<List<RoleEntity>> getRoles();
  
  Future<Map<String, dynamic>> getUsers({
    int page = 1, 
    int limit = 10, 
    String? search, 
    String? status 
  });
  
  Future<UserEntity> getUserDetail(String userId);
  
  Future<void> createUser(Map<String, dynamic> userData);
  
  Future<void> updateUser(String userId, Map<String, dynamic> userData);
}