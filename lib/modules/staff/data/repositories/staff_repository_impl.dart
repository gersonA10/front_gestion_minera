import 'package:front_gestion_minera/modules/staff/data/models/models.dart';
import 'package:front_gestion_minera/modules/staff/data/models/payroll_monthly_model.dart';

import '../../domain/entity/entity.dart';
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

  @override
  Future<void> registerEmployees(RegisterEmployeesEntity employees) =>
    datasource.registerEmployees(employees);

  @override
  Future<void> createPayrollMonthly(CreatePayrollMonthlyEntity payrollMonthly) =>
    datasource.createPayrollMonthly(payrollMonthly);

  @override
  Future<List<PayrollMonthlyModel>> getPayrollMonthly() {
    return datasource.getPayrollMonthly();
  }
  @override
  Future<void> registerCheckInEmployee(EmployeeCheckInEntity checkIn) =>
    datasource.registerCheckInEmployee(checkIn);
}