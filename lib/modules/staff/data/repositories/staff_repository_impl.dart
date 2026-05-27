import '../../domain/entity/employee_entity.dart';
import '../../domain/entity/paginated_employees_entity.dart';
import 'package:front_gestion_minera/modules/staff/data/models/models.dart';
import 'package:front_gestion_minera/modules/staff/data/models/payroll_monthly_model.dart';

import '../../domain/entity/entity.dart';
import '../../domain/repositories/staff_repository.dart';
import '../datasource/staff_datasource.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffDatasource datasource;

  StaffRepositoryImpl({required this.datasource});

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
  Future<void> createPayrollMonthly(
    CreatePayrollMonthlyEntity payrollMonthly,
  ) => datasource.createPayrollMonthly(payrollMonthly);

  @override
  Future<List<PayrollMonthlyModel>> getPayrollMonthly() {
    return datasource.getPayrollMonthly();
  }

  @override
  Future<EmployeeEntity> getEmployeeById(String id) async {
    return await datasource.getEmployeeById(id);
  }

  @override
  Future<List<AttendanceIngresoEntity>> getAttendanceIngreso() =>
      datasource.getAttendanceIngreso();

  @override
  Future<List<AttendanceEnPlantaEntity>> getAttendanceEnPlanta() =>
      datasource.getAttendanceEnPlanta();

  @override
  Future<List<AttendanceFinalizadoEntity>> getAttendanceFinalizado({
    required String date,
  }) => datasource.getAttendanceFinalizado(date: date);
  @override
  Future<EmployeeCheckOutResponseEntity> checkOutEmployee(
    String attendanceId,
    EmployeeCheckOutRequestEntity request,
  ) async {
    final requestModel = EmployeeCheckOutRequestModel.fromEntity(request);

    return await datasource.checkOutEmployee(attendanceId, requestModel);
  }
}
