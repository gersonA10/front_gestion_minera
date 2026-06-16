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
  Future<EmployeeEntity> getEmployeeById(String id);
  Future<void> updateEmployee(String id, Map<String, dynamic> data);
  Future<void> requestEmployeePayment({
    required String employeeId,
    required String employeeName,
    required String requestType,
    required double amount,
    required String justification,
    required String imagePath,
  });
  Future<List<EgresoDetailItemEntity>> getEgresoDetail(String requestId);
  Future<EmployeeBalanceEntity> getEmployeeBalance(String employeeId);

  Future<List<AttendanceIngresoEntity>> getAttendanceIngreso();
  Future<List<AttendanceEnPlantaEntity>> getAttendanceEnPlanta();
  Future<List<AttendanceFinalizadoEntity>> getAttendanceFinalizado({
    required String date,
  });
  Future<EmployeeCheckOutResponseEntity> checkOutEmployee(
    String attendanceId,
    EmployeeCheckOutRequestEntity request,
  );

  Future<void> registerCheckInEmployee(EmployeeCheckInEntity checkIn);

  Future<EmployeeDetailAssistanceModel> getDetailsEmployee(String employeeId);
  Future<List<PayrollMonthlyEntity>> getPayrollMonthlyList({
    required int month,
    required int year,
  });
  Future<HistoryExpenditureResponseModel> getHistoryExpenditure({
    int page = 1,
    int limit = 10,
    String? year,
    String? status,
  });
  Future<PayrollHistoryResponseModel> getPayrollHistory({
    required int year,
    required int page,
    required int limit,
  });
  Future<ProcessPayrollPaymentEntity> processPayrollPayment({
  required String payrollId,
  required String idempotencyKey,
});
}
