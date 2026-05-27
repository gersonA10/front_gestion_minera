import '../entity/employee_entity.dart';
import '../entity/paginated_employees_entity.dart';

abstract class StaffRepository {
  Future<PaginatedEmployeesEntity> getEmployees({
    String? search,
    String? department,
    String? status,
    int page = 1,
    int limit = 20,
  });

  Future<EmployeeEntity> getEmployeeById(String id);
}
