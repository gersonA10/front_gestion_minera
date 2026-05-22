import '../../domain/entity/paginated_employees_entity.dart';
import '../../domain/repositories/staff_repository.dart';
import '../datasource/staff_datasource.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffDatasource datasource;

  StaffRepositoryImpl({
    required this.datasource,
  });

  @override
  Future<PaginatedEmployeesEntity> getEmployees({
    String? search,
    String? department,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    return await datasource.getEmployees(
      search: search,
      department: department,
      status: status,
      page: page,
      limit: limit,
    );
  }
}