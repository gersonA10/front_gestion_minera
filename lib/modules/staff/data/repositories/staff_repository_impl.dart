import 'package:front_gestion_minera/modules/staff/data/models/models.dart';
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
  Future<void> updateEmployee(String id, Map<String, dynamic> data) =>
      datasource.updateEmployee(id, data);

  @override
  Future<void> requestEmployeePayment({
    required String employeeId,
    required String employeeName,
    required String requestType,
    required double amount,
    required String justification,
    required String imagePath,
  }) =>
      datasource.requestEmployeePayment(
        employeeId: employeeId,
        employeeName: employeeName,
        requestType: requestType,
        amount: amount,
        justification: justification,
        imagePath: imagePath,
      );

  @override
  Future<List<EgresoDetailItemEntity>> getEgresoDetail(String requestId) =>
      datasource.getEgresoDetail(requestId);

  @override
  Future<EmployeeBalanceEntity> getEmployeeBalance(String employeeId) =>
      datasource.getEmployeeBalance(employeeId);

  @override
  Future<double> getCashBalance() => datasource.getCashBalance();

  @override
  Future<List<CashMovementEntity>> getCashMovements() =>
      datasource.getCashMovements();

  @override
  Future<List<CashPayableEntity>> getCashPayables() =>
      datasource.getCashPayables();

  @override
  Future<void> payPayrollFromCash(String payrollId) =>
      datasource.payPayrollFromCash(payrollId);

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
  Future<void> registerCheckInEmployee(EmployeeCheckInEntity checkIn) =>
      datasource.registerCheckInEmployee(checkIn);

  @override
  Future<EmployeeCheckOutResponseEntity> checkOutEmployee(
    String attendanceId,
    EmployeeCheckOutRequestEntity request,
  ) async {
    final requestModel = EmployeeCheckOutRequestModel.fromEntity(request);

    return await datasource.checkOutEmployee(attendanceId, requestModel);
  }

  @override
  Future<EmployeeDetailAssistanceModel> getDetailsEmployee(String employeeId) {
    return datasource.getDetailsEmployee(employeeId);
  }

  @override
  Future<List<PayrollMonthlyEntity>> getPayrollMonthlyList({
    required int month,
    required int year,
  }) {
    return datasource.getPayrollMonthlyList(month: month, year: year);
  }

  Future<HistoryExpenditureResponseModel> getHistoryExpenditure({
    int page = 1,
    int limit = 10,
    String? year,
    String? status,
  }) {
    return datasource.getHistoryExpenditure(
      page: page,
      limit: limit,
      year: year,
      status: status,
    );
  }

  @override
  Future<PayrollHistoryResponseModel> getPayrollHistory({
    required int year,
    required int page,
    required int limit,
  }) {
    return datasource.getPayrollHistory(year: year, page: page, limit: limit);
  }

  Future<ProcessPayrollPaymentEntity> processPayrollPayment({
    required String payrollId,
    required String idempotencyKey,
    double? amount,
  }) async {
    return await datasource.processPayrollPayment(
      payrollId: payrollId,
      idempotencyKey: idempotencyKey,
      amount: amount,
    );
  }
}
