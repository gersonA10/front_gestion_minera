import 'employee_entity.dart';

class PaginatedEmployeesEntity {
  final int total;
  final int page;
  final int limit;
  final bool hasMore;
  final List<EmployeeEntity> employees;

  const PaginatedEmployeesEntity({
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
    required this.employees,
  });

  int get totalPages => (total / limit).ceil();
}