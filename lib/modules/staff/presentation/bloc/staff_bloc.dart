import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/networking/base_api_exception.dart';
import 'package:front_gestion_minera/modules/staff/data/models/models.dart';
import 'package:front_gestion_minera/utils/error.dart';
import '../../domain/repositories/staff_repository.dart';
import '../../domain/entity/entity.dart';
import 'dart:async';
part 'staff_event.dart';
part 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  //History Expenditure
  int _currentPageHistory = 1;
  bool _hasReachedMaxHistory = false;
  int _currentTotalHistory = 0;
  List<HistoryExpenditureEntity> _historyExpenditure = [];
  bool _isLoadingMoreHistory = false;
  String? _yearHistory;
  String? _statusHistory;

  final StaffRepository repository;
  StaffBloc({required this.repository}) : super(StaffInitial()) {
    on<GetEmployeesEvent>(_onGetEmployees);
    on<LoadMoreEmployeesEvent>(_onLoadMoreEmployees);
    on<RefreshEmployeesEvent>(_onRefreshEmployees);
    on<RegisterEmployeesEvent>(_onRegisterEmployees);
    on<CreatePayrollMonthlyEvent>(_onCreatePayrollMonthly);
    on<GetEmployeePayrollEvent>(_onGetEmployeePayrol);
    on<GetEmployeeProfileEvent>(_onGetEmployeeProfile);
    on<UpdateEmployeeProfileEvent>(_onUpdateEmployeeProfile);
    on<RequestEmployeePaymentEvent>(_onRequestEmployeePayment);
    on<GetEgresoDetailEvent>(_onGetEgresoDetail);
    on<GetEmployeeBalanceEvent>(_onGetEmployeeBalance);
    on<GetAttendanceIngresoEvent>(_onGetAttendanceIngreso);
    on<GetAttendanceEnPlantaEvent>(_onGetAttendanceEnPlanta);
    on<GetAttendanceFinalizadoEvent>(_onGetAttendanceFinalizado);
    on<CheckOutEmployeeEvent>(_onCheckOutEmployee);
    on<RegisterCheckInEmployeeEvent>(_onRegisterCheckInEmployee);
    on<GetDetailAssistanceEmployeeEvent>(_onGetDetailAssistanceEmployee);
    on<GetPayrollMonthlyListEvent>(_onGetPayrollMonthlyList);
    on<GetHistoryRecordExpenditureEvent>(_onGetHistoryRecordExpenditure);
    on<LoadMoreHistoryRecordExpenditureEvent>(
      _onLoadMoreHistoryRecordExpenditure,
    );
    on<GetPayrollHistoryEvent>(_onGetPayrollHistory);
    on<ProcessPayrollPaymentEvent>(_onProcessPayrollPayment);
  }

  FutureOr<void> _onRegisterEmployees(
    RegisterEmployeesEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(RegisterEmployeesLoading());
    try {
      await repository.registerEmployees(event.employeed);
      emit(RegisterEmployeesSuccess());
    } on BaseApiException catch (error) {
      final errorData = error.response?.data;
      final responseData =
          errorData is Map<String, dynamic> ? errorData : null;
      emit(RegisterEmployeesError(responseData?['error'] ?? error.key));
    } catch (e) {
      emit(RegisterEmployeesError('Error inesperado: $e'));
    }
  }

  Future<void> _onGetEmployees(
    GetEmployeesEvent event,
    Emitter<StaffState> emit,
  ) async {
    try {
      if (state is EmployeesLoaded) {
        emit(EmployeesPageLoading(state as EmployeesLoaded));
      } else {
        emit(EmployeesLoading());
      }

      final response = await repository.getEmployees(
        search: event.search,
        department: event.department,
        status: event.status,
        page: event.page,
        limit: event.limit,
      );

      emit(
        EmployeesLoaded(
          employees: response.employees,
          hasMore: response.hasMore,
          total: response.total,
          currentPage: response.page,
          totalPages: response.totalPages,
          currentSearch: event.search,
          currentDepartment: event.department,
          currentStatus: event.status,
        ),
      );
    } on BaseApiException catch (e) {
      emit(EmployeesError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(EmployeesError('Ocurrió un error inesperado'));
    }
  }

  Future<void> _onLoadMoreEmployees(
    LoadMoreEmployeesEvent event,
    Emitter<StaffState> emit,
  ) async {
    final currentState = state;

    if (currentState is! EmployeesLoaded) return;
    if (!currentState.hasMore) return;

    final nextPage = currentState.currentPage + 1;

    try {
      final response = await repository.getEmployees(
        search: currentState.currentSearch,
        department: currentState.currentDepartment,
        status: currentState.currentStatus,
        page: nextPage,
      );

      emit(
        currentState.copyWith(
          employees: [...currentState.employees, ...response.employees],
          currentPage: response.page,
          hasMore: response.hasMore,
        ),
      );
    } on BaseApiException catch (e) {
      emit(EmployeesError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(EmployeesError('Ocurrió un error inesperado'));
    }
  }

  Future<void> _onRefreshEmployees(
    RefreshEmployeesEvent event,
    Emitter<StaffState> emit,
  ) async {
    final currentState = state;
    if (currentState is! EmployeesLoaded) return;

    add(
      GetEmployeesEvent(
        search: currentState.currentSearch,
        department: currentState.currentDepartment,
        status: currentState.currentStatus,
      ),
    );
  }

  FutureOr<void> _onCreatePayrollMonthly(
    CreatePayrollMonthlyEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(CreatePayrollRequestLoading());
    try {
      await repository.createPayrollMonthly(event.payroll);
      emit(CreatePayrollRequestSuccess());
    } on BaseApiException catch (error) {
      final errorData = error.response?.data;
      final responseData =
          errorData is Map<String, dynamic> ? errorData : null;
      emit(CreatePayrollRequestError(responseData?['error'] ?? error.key));
    } catch (e) {
      emit(CreatePayrollRequestError('Error inesperado: $e'));
    }
  }

  FutureOr<void> _onGetEmployeePayrol(
    GetEmployeePayrollEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(GenerateEmployeePayrollLoading());
    try {
      final response = await repository.getPayrollMonthly();
      final totalEmployee = response.length;
      double totalAmount = response.fold(
        0,
        (sum, employee) => sum + employee.baseSalary,
      );
      emit(
        GenerateEmployeePayrollSuccess(
          totalEmployee: totalEmployee,
          totalAmount: totalAmount,
        ),
      );
    } on BaseApiException catch (error) {
      final errorData = error.response?.data;
      final responseData =
          errorData is Map<String, dynamic> ? errorData : null;
      emit(GenerateEmployeePayrollError(responseData?['error'] ?? error.key));
    } catch (e) {
      emit(GenerateEmployeePayrollError('Error inesperado: $e'));
    }
  }

  Future<void> _onGetEmployeeProfile(
    GetEmployeeProfileEvent event,
    Emitter<StaffState> emit,
  ) async {
    try {
      emit(EmployeeProfileLoading());
      final employee = await repository.getEmployeeById(event.employeeId);
      emit(EmployeeProfileLoaded(employee));
    } on BaseApiException catch (e) {
      emit(EmployeeProfileError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(EmployeeProfileError('Ocurrió un error inesperado'));
    }
  }

  Future<void> _onUpdateEmployeeProfile(
    UpdateEmployeeProfileEvent event,
    Emitter<StaffState> emit,
  ) async {
    try {
      final data = <String, dynamic>{};
      if (event.status != null) data['status'] = event.status;
      if (event.shiftType != null && event.shiftType!.trim().isNotEmpty) {
        data['shift_type'] = event.shiftType!.trim();
      }

      await repository.updateEmployee(event.employeeId, data);

      // Recarga el perfil con los datos frescos del backend.
      final employee = await repository.getEmployeeById(event.employeeId);
      emit(EmployeeProfileUpdateSuccess(employee));
      emit(EmployeeProfileLoaded(employee));
    } on BaseApiException catch (e) {
      emit(EmployeeProfileUpdateError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(EmployeeProfileUpdateError('Ocurrió un error inesperado'));
    }
  }

  Future<void> _onGetEgresoDetail(
    GetEgresoDetailEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(EgresoDetailLoading());
    try {
      final items = await repository.getEgresoDetail(event.requestId);
      emit(EgresoDetailLoaded(items));
    } on BaseApiException catch (e) {
      emit(EgresoDetailError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(EgresoDetailError('Ocurrió un error inesperado'));
    }
  }

  Future<void> _onGetEmployeeBalance(
    GetEmployeeBalanceEvent event,
    Emitter<StaffState> emit,
  ) async {
    try {
      final balance = await repository.getEmployeeBalance(event.employeeId);
      emit(EmployeeBalanceLoaded(balance));
    } catch (_) {
      // El balance es informativo; si falla no bloqueamos el perfil.
    }
  }

  Future<void> _onRequestEmployeePayment(
    RequestEmployeePaymentEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(EmployeePaymentRequestLoading());
    try {
      await repository.requestEmployeePayment(
        employeeId: event.employeeId,
        employeeName: event.employeeName,
        requestType: event.requestType,
        amount: event.amount,
        justification: event.justification,
        imagePath: event.imagePath,
      );
      emit(EmployeePaymentRequestSuccess());
    } on BaseApiException catch (e) {
      emit(EmployeePaymentRequestError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(EmployeePaymentRequestError('Ocurrió un error inesperado'));
    }
  }

  Future<void> _onGetAttendanceIngreso(
    GetAttendanceIngresoEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(AttendanceIngresoLoading());
    try {
      final employees = await repository.getAttendanceIngreso();
      emit(AttendanceIngresoLoaded(employees));
    } on BaseApiException catch (e) {
      emit(AttendanceIngresoError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(AttendanceIngresoError('Ocurrió un error inesperado'));
    }
  }

  Future<void> _onGetAttendanceEnPlanta(
    GetAttendanceEnPlantaEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(AttendanceEnPlantaLoading());
    try {
      final employees = await repository.getAttendanceEnPlanta();
      emit(AttendanceEnPlantaLoaded(employees));
    } on BaseApiException catch (e) {
      emit(AttendanceEnPlantaError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(AttendanceEnPlantaError('Ocurrió un error inesperado'));
    }
  }

  Future<void> _onGetAttendanceFinalizado(
    GetAttendanceFinalizadoEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(AttendanceFinalizadoLoading());
    try {
      final employees = await repository.getAttendanceFinalizado(
        date: event.date,
      );
      emit(AttendanceFinalizadoLoaded(employees));
    } on BaseApiException catch (e) {
      emit(AttendanceFinalizadoError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(AttendanceFinalizadoError('Ocurrió un error inesperado'));
    }
  }

  Future<void> _onCheckOutEmployee(
    CheckOutEmployeeEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(CheckOutEmployeeLoading());

    try {
      final response = await repository.checkOutEmployee(
        event.attendanceId,
        event.request,
      );

      emit(CheckOutEmployeeSuccess(response));
    } on BaseApiException catch (e) {
      final errorData = e.response?.data;
      final responseData =
          errorData is Map<String, dynamic> ? errorData : null;
      emit(
        CheckOutEmployeeError(responseData?['error'] ?? mapErrorMessage(e.key)),
      );
    } catch (e) {
      emit(CheckOutEmployeeError('Error inesperado: $e'));
    }
  }

  FutureOr<void> _onRegisterCheckInEmployee(
    RegisterCheckInEmployeeEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(CheckInEmployeeLoading());
    try {
      await repository.registerCheckInEmployee(event.checkIn);
      emit(CheckInEmployeeSuccess());
    } on BaseApiException catch (error) {
      final errorData = error.response?.data;
      final responseData =
          errorData is Map<String, dynamic> ? errorData : null;
      emit(CheckInEmployeeError(responseData?['error'] ?? error.key));
    } catch (e) {
      emit(CheckInEmployeeError('Error inesperado: $e'));
    }
  }

  FutureOr<void> _onGetDetailAssistanceEmployee(
    GetDetailAssistanceEmployeeEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(DetailAssistanceEmployeeLoading());
    try {
      final employee = await repository.getDetailsEmployee(event.employeeId);
      emit(DetailAssistanceEmployeeLoaded(employee: employee));
    } on BaseApiException catch (error) {
      final errorData = error.response?.data;
      final responseData =
          errorData is Map<String, dynamic> ? errorData : null;
      emit(DetailAssistanceEmployeeError(responseData?['error'] ?? error.key));
    } catch (e) {
      emit(DetailAssistanceEmployeeError('Error inesperado: $e'));
    }
  }

  Future<void> _onGetPayrollMonthlyList(
    GetPayrollMonthlyListEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(PayrollMonthlyLoading());
    try {
      final payrolls = await repository.getPayrollMonthlyList(
        month: event.month,
        year: event.year,
      );
      double totalPayroll = 0;
      double totalPaid = 0;
      double totalPending = 0;
      for (final payroll in payrolls) {
        totalPayroll += payroll.netTotal;
        if (payroll.paymentStatus.toUpperCase() == 'PAGADO') {
          totalPaid += payroll.netTotal;
        } else {
          totalPending += payroll.netTotal;
        }
      }
      emit(
        PayrollMonthlyLoaded(
          payrolls: payrolls,
          totalPayroll: totalPayroll,
          totalPaid: totalPaid,
          totalPending: totalPending,
        ),
      );
    } on BaseApiException catch (error) {
      final data = error.response?.data;
      final responseData = data is Map<String, dynamic> ? data : null;
      emit(
        PayrollMonthlyError(
          responseData?['error'] ?? mapErrorMessage(error.key),
        ),
      );
    } catch (e) {
      emit(PayrollMonthlyError('Error inesperado: $e'));
    }
  }

  FutureOr<void> _onGetHistoryRecordExpenditure(
    GetHistoryRecordExpenditureEvent event,
    Emitter<StaffState> emit,
  ) async {
    if (event.isRefresh) {
      _currentPageHistory = 1;
      _hasReachedMaxHistory = false;
      _isLoadingMoreHistory = false;

      _yearHistory = event.year;
      _statusHistory = event.state;
      emit(HistoryRecordExpenditureLoading());
    }
    try {
      final response = await repository.getHistoryExpenditure(
        status: _statusHistory,
        year: _yearHistory,
      );
      _historyExpenditure = response.items;
      _currentTotalHistory = response.total;
      _hasReachedMaxHistory = !response.hasMore;
      emit(
        HistoryRecordExpenditureLoaded(
          items: _historyExpenditure,
          hasMore: response.hasMore,
          total: _currentTotalHistory,
          totalExpenses: response.totalExpenses,
        ),
      );
    } on BaseApiException catch (error) {
      final errorData = error.response?.data;
      final responseData =
          errorData is Map<String, dynamic> ? errorData : null;
      emit(HistoryRecordExpenditureError(responseData?['error'] ?? error.key));
    } catch (e) {
      emit(HistoryRecordExpenditureError('Error inesperado: $e'));
    }
  }

  FutureOr<void> _onLoadMoreHistoryRecordExpenditure(
    LoadMoreHistoryRecordExpenditureEvent event,
    Emitter<StaffState> emit,
  ) async {
    if (_hasReachedMaxHistory || _isLoadingMoreHistory) {
      return;
    }
    _isLoadingMoreHistory = true;
    _currentPageHistory++;
    emit(HistoryRecordExpenditureLoading());
    try {
      final response = await repository.getHistoryExpenditure(
        status: _statusHistory,
        year: _yearHistory,
        page: _currentPageHistory,
      );
      _historyExpenditure.addAll(response.items);
      _hasReachedMaxHistory = !response.hasMore;
      emit(
        HistoryRecordExpenditureLoaded(
          items: List.from(_historyExpenditure),
          hasMore: response.hasMore,
          total: _currentTotalHistory,
          totalExpenses: response.totalExpenses,
        ),
      );
    } on BaseApiException catch (error) {
      final errorData = error.response?.data;
      final responseData =
          errorData is Map<String, dynamic> ? errorData : null;
      emit(HistoryRecordExpenditureError(responseData?['error'] ?? error.key));
    } catch (e) {
      emit(HistoryRecordExpenditureError('Error inesperado: $e'));
    }
  }

  Future<void> _onGetPayrollHistory(
    GetPayrollHistoryEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(PayrollHistoryLoading());
    try {
      final history = await repository.getPayrollHistory(
        year: event.year,
        page: event.page,
        limit: event.limit,
      );
      emit(PayrollHistoryLoaded(history: history));
    } on BaseApiException catch (error) {
      final errorData = error.response?.data;
      final responseData =
          errorData is Map<String, dynamic> ? errorData : null;
      emit(
        PayrollHistoryError(
          message: responseData?['error'] ?? mapErrorMessage(error.key),
        ),
      );
    } catch (e) {
      emit(PayrollHistoryError(message: 'Error inesperado: $e'));
      }
      }

  Future<void> _onProcessPayrollPayment(
    ProcessPayrollPaymentEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(ProcessPayrollPaymentLoading());
    try {
      final response = await repository.processPayrollPayment(
        payrollId: event.payrollId,
        idempotencyKey: event.idempotencyKey,
      );
      emit(ProcessPayrollPaymentSuccess(response));
    } catch (e) {
      emit(ProcessPayrollPaymentError(e.toString()));
    }
  }
}
