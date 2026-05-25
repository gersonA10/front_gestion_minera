import '../entity/entity.dart';

abstract class StaffRepository {
  Future<PaginatedEmployeesEntity> getEmployees({
    String? search,
    String? department,
    String? status,
    int page = 1,
    int limit = 20,
  });
  
  Future<void> registerEmployees(RegisterEmployeesEntity employees);
}