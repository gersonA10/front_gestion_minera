import '../../domain/entity/paginated_employees_entity.dart';
import 'employee_model.dart';

class PaginatedEmployeesModel extends PaginatedEmployeesEntity {
  const PaginatedEmployeesModel({
    required super.total,
    required super.page,
    required super.limit,
    required super.hasMore,
    required super.employees,
  });

  factory PaginatedEmployeesModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    final int total = data['total'] ?? 0;
    final int page = data['page'] ?? 1;
    final int limit = data['limit'] ?? 20;

    final employees = (data['employees'] as List<dynamic>? ?? [])
        .map((employee) => EmployeeModel.fromJson(employee))
        .toList();

    final hasMore = (page * limit) < total;

    return PaginatedEmployeesModel(
      total: total,
      page: page,
      limit: limit,
      hasMore: hasMore,
      employees: employees,
    );
  }
}
