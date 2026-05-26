import 'package:front_gestion_minera/modules/staff/data/models/models.dart';

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

  Future<List<PayrollMonthlyModel>> getPayrollMonthly();
  Future<void> createPayrollMonthly(CreatePayrollMonthlyEntity payrollMonthly);

  Future<void> registerCheckInEmployee(EmployeeCheckInEntity checkIn);
}