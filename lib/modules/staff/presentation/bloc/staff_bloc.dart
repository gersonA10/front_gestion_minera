import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/networking/base_api_exception.dart';
import 'package:front_gestion_minera/utils/error.dart';
import '../../domain/repositories/staff_repository.dart';
import '../../domain/entity/entity.dart';
import 'dart:async';
part 'staff_event.dart';
part 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final StaffRepository repository;
  StaffBloc({required this.repository}) : super(StaffInitial()) {
    on<GetEmployeesEvent>(_onGetEmployees);
    on<LoadMoreEmployeesEvent>(_onLoadMoreEmployees);
    on<RefreshEmployeesEvent>(_onRefreshEmployees);
    on<RegisterEmployeesEvent>(_onRegisterEmployees);
    on<CreatePayrollMonthlyEvent>(_onCreatePayrollMonthly);
    on<GetEmployeePayrollEvent>(_onGetEmployeePayrol);
    on<GetEmployeeProfileEvent>(_onGetEmployeeProfile);
    on<GetAttendanceIngresoEvent>(_onGetAttendanceIngreso);
    on<GetAttendanceEnPlantaEvent>(_onGetAttendanceEnPlanta);
    on<GetAttendanceFinalizadoEvent>(_onGetAttendanceFinalizado);
<<<<<<< HEAD
    on<CheckOutEmployeeEvent>(_onCheckOutEmployee);
=======
    on<RegisterCheckInEmployeeEvent>(_onRegisterCheckInEmployee);
>>>>>>> origin/dev
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
      final responseData = error.response?.data as Map<String, dynamic>?;
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
      final responseData = error.response?.data as Map<String, dynamic>?;
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
      final responseData = error.response?.data as Map<String, dynamic>?;
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
<<<<<<< HEAD

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
      final responseData = e.response?.data as Map<String, dynamic>?;
      emit(
        CheckOutEmployeeError(responseData?['error'] ?? mapErrorMessage(e.key)),
      );
    } catch (e) {
      emit(CheckOutEmployeeError('Error inesperado: $e'));
    }
  }
=======
  FutureOr<void> _onRegisterCheckInEmployee(
    RegisterCheckInEmployeeEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(CheckInEmployeeLoading());
    try {
      await repository.registerCheckInEmployee(event.checkIn);
      emit(CheckInEmployeeSuccess());
    }on BaseApiException catch (error) {
      final responseData = error.response?.data as Map<String, dynamic>?;
      emit(CheckInEmployeeError(responseData?['error'] ?? error.key));
    } catch (e) {
      emit(CheckInEmployeeError('Error inesperado: $e'));}}
>>>>>>> origin/dev
}
