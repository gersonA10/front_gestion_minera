import 'package:dio/dio.dart';
import 'package:front_gestion_minera/core/networking/http_services.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/entity.dart';
import '../models/models.dart';

class StaffDatasource {
  final ApiClient apiClient;

  StaffDatasource({required this.apiClient});

  Future<PaginatedEmployeesModel> getEmployees({
    String? search,
    String? department,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final Map<String, dynamic> queryParameters = {'page': page, 'limit': limit};

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    if (department != null && department.trim().isNotEmpty) {
      queryParameters['department'] = department.trim();
    }

    if (status != null &&
        status.trim().isNotEmpty &&
        status.toLowerCase() != 'todos') {
      queryParameters['status'] = status.trim();
    }

    final response = await apiClient.get(
      '/api/hr/employees',
      operationName: 'getEmployees',
      queryParameters: queryParameters,
    );

    return PaginatedEmployeesModel.fromJson(response);
  }

  Future<void> registerEmployees(RegisterEmployeesEntity employees) async {
    final model = RegisterEmployeesModel.fromEntity(employees);
    await apiClient.post(
      '/api/hr/employees',
      operationName: 'registerEmployeed',
      data: model.toJson(),
    );
  }

  /// Actualización parcial de un empleado (PATCH). Solo se envían los campos
  /// presentes en [data] (p.ej. {'shift_type': ..., 'status': ...}).
  Future<void> updateEmployee(String id, Map<String, dynamic> data) async {
    await apiClient.patch(
      '/api/hr/employees/$id',
      operationName: 'updateEmployee',
      data: data,
    );
  }

  Future<List<PayrollMonthlyModel>> getPayrollMonthly() async {
    final queryParameters = {
      'month': DateTime.now().month.toString(),
      'year': DateTime.now().year.toString(),
    };
    final response = await apiClient.get(
      '/api/hr/payrolls',
      operationName: 'getPayrollsMonthly',
      queryParameters: queryParameters,
    );
    final List data = response as List;
    return data.map((json) => PayrollMonthlyModel.fromJson(json)).toList();
  }

  Future<void> createPayrollMonthly(
    CreatePayrollMonthlyEntity payrollenitity,
  ) async {
    final modelpayroll = CreatePayrollMonthlyModel.fromEntity(payrollenitity);
    await apiClient.postFormData(
      '/api/hr/payrolls/request-egreso',
      operationName: 'requestPayrollsMonthly',
      data: modelpayroll.toJson(),
      files: [
        {
          'name': 'planilla',
          'path': modelpayroll.planillaUrl,
          'filename': modelpayroll.planillaUrl.split('/').last,
        },
      ],
    );
  }

  /// Detalle de un egreso: nóminas por trabajador ligadas a [requestId].
  Future<List<EgresoDetailItemModel>> getEgresoDetail(String requestId) async {
    final response = await apiClient.get(
      '/api/hr/payroll-egresos/$requestId/detail',
      operationName: 'getEgresoDetail',
    );
    final List data = (response['data'] as List?) ?? [];
    return data
        .map((e) => EgresoDetailItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Saldo de la Caja de Personal del jefe.
  Future<double> getCashBalance() async {
    final response = await apiClient.get(
      '/api/hr/cash/balance',
      operationName: 'getCashBalance',
    );
    return (response['data']?['current_balance'] ?? 0).toDouble();
  }

  /// Movimientos de la Caja de Personal.
  Future<List<CashMovementModel>> getCashMovements() async {
    final response = await apiClient.get(
      '/api/hr/cash/movements',
      operationName: 'getCashMovements',
    );
    final List data = (response['data'] as List?) ?? [];
    return data
        .map((e) => CashMovementModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Nóminas pendientes por pagar.
  Future<List<CashPayableModel>> getCashPayables() async {
    final response = await apiClient.get(
      '/api/hr/cash/payables',
      operationName: 'getCashPayables',
    );
    final List data = (response['data'] as List?) ?? [];
    return data
        .map((e) => CashPayableModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Paga una nómina desde la Caja de Personal.
  Future<void> payPayrollFromCash(String payrollId) async {
    await apiClient.post(
      '/api/hr/cash/pay-payroll',
      operationName: 'payPayrollFromCash',
      data: {'payroll_id': payrollId},
    );
  }

  /// Balance del trabajador (total pendiente y atrasado).
  Future<EmployeeBalanceModel> getEmployeeBalance(String employeeId) async {
    final response = await apiClient.get(
      '/api/hr/employees/$employeeId/balance',
      operationName: 'getEmployeeBalance',
    );
    return EmployeeBalanceModel.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }

  /// Solicita a Hacienda un pago individual (adelanto o saldo) para un trabajador.
  Future<void> requestEmployeePayment({
    required String employeeId,
    required String employeeName,
    required String requestType, // 'ADELANTO' | 'SALDO'
    required double amount,
    required String justification,
    required String imagePath,
  }) async {
    await apiClient.postFormData(
      '/api/hr/employees/payment-request',
      operationName: 'requestEmployeePayment',
      data: {
        'employee_id': employeeId,
        'employee_name': employeeName,
        'request_type': requestType,
        'amount': amount.toString(),
        'justification': justification,
      },
      files: [
        {
          'name': 'planilla',
          'path': imagePath,
          'filename': imagePath.split('/').last,
        },
      ],
    );
  }

  Future<EmployeeCheckOutModel> checkOutEmployee(
    String attendanceId,
    EmployeeCheckOutRequestModel request,
  ) async {
    final response = await apiClient.patch(
      '/api/hr/employees/attendances/$attendanceId/check-out',
      data: request.toJson(),
      operationName: 'checkOutEmployee',
    );

    return EmployeeCheckOutModel.fromJson(response['data']);
  }

  Future<EmployeeModel> getEmployeeById(String id) async {
    final response = await apiClient.get(
      '/api/hr/employees/$id',
      operationName: 'getEmployeeById',
    );
    return EmployeeModel.fromJson(response['data']);
  }

  Future<List<AttendanceIngresoModel>> getAttendanceIngreso() async {
    final response = await apiClient.get(
      '/api/hr/attendances/daily',
      operationName: 'getAttendanceIngreso',
      queryParameters: {'tab': 'INGRESO'},
    );
    final List data = (response['pending_employees'] as List?) ?? [];
    return data
        .map((e) => AttendanceIngresoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AttendanceEnPlantaModel>> getAttendanceEnPlanta() async {
    final response = await apiClient.get(
      '/api/hr/attendances/daily',
      operationName: 'getAttendanceEnPlanta',
      queryParameters: {'tab': 'EN_PLANTA'},
    );
    final List data = (response['employees'] as List?) ?? [];
    return data
        .map((e) => AttendanceEnPlantaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AttendanceFinalizadoModel>> getAttendanceFinalizado({
    required String date,
  }) async {
    final response = await apiClient.get(
      '/api/hr/attendances/daily',
      operationName: 'getAttendanceFinalizado',
      queryParameters: {'tab': 'FINALIZADOS', 'date': date},
    );
    final List data = (response['records'] as List?) ?? [];
    return data
        .map(
          (e) => AttendanceFinalizadoModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> registerCheckInEmployee(EmployeeCheckInEntity checkIn) async {
    final model = EmployeeCheckInModel.fromEntity(checkIn);
    await apiClient.post(
      '/api/hr/attendances/check-in',
      operationName: 'CheckInEmployeed',
      data: model.toJson(),
    );
  }

  Future<EmployeeDetailAssistanceModel> getDetailsEmployee(
    String employeeId,
  ) async {
    final response = await apiClient.get(
      '/api/hr/attendances/$employeeId',
      operationName: 'getDetailsEmployee',
    );
    return EmployeeDetailAssistanceModel.fromJson(response['data']);
  }

  Future<List<PayrollMonthlyModel>> getPayrollMonthlyList({
    required int month,
    required int year,
  }) async {
    final response = await apiClient.get(
      '/api/hr/payrolls',
      operationName: 'getPayrollMonthlyList',
      queryParameters: {'month': month.toString(), 'year': year.toString()},
    );

    final List data = response as List;

    return data
        .map(
          (item) => PayrollMonthlyModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<HistoryExpenditureResponseModel> getHistoryExpenditure({
    String? year,
    String? status = 'TODOS',
    int page = 1,
    int limit = 10,
  }) async {
    year ??= DateTime.now().year.toString();
    final queryParameters = {
      'page': page,
      'limit': limit,
      'year': year,
      'status': status,
    };
    final response = await apiClient.get(
      '/api/hr/payroll-egresos',
      operationName: 'payrollHistory',
      queryParameters: queryParameters,
    );
    return HistoryExpenditureResponseModel.fronJson(response);
  }

  Future<PayrollHistoryResponseModel> getPayrollHistory({
    required int year,
    required int page,
    required int limit,
  }) async {
    final response = await apiClient.get(
      '/api/hr/payrolls/history',
      operationName: 'getPayrollHistory',
      queryParameters: {'year': year, 'page': page, 'limit': limit},
    );

    return PayrollHistoryResponseModel.fromJson(response);
  }

  Future<ProcessPayrollPaymentModel> processPayrollPayment({
    required String payrollId,
    required String idempotencyKey,
    double? amount,
  }) async {
    final response = await apiClient.patch(
      '/api/hr/payrolls/$payrollId/pay',
      operationName: 'processPayrollPayment',
      data: amount == null ? {} : {'amount': amount},
      options: Options(headers: {'X-Idempotency-Key': idempotencyKey}),
    );

    return ProcessPayrollPaymentModel.fromJson(response['data']);
  }
}
