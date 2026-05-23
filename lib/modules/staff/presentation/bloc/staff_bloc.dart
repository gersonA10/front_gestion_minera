import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entity/entity.dart';
import '../../domain/repositories/staff_repository.dart';
import 'dart:async';
import '../../../../core/networking/base_api_exception.dart';
import '../../../../utils/error.dart';

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

    if (currentState is! EmployeesLoaded) {
      return;
    }

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
    emit(CreatePayrollMonthlyLoading());
    try {
      await repository.createPayrollMonthly(event.payroll);
      emit(CreatePayrollMonthlySuccess());
    } on BaseApiException catch (error) {
      final responseData = error.response?.data as Map<String, dynamic>?;
      emit(CreatePayrollMonthlyError(responseData?['error'] ?? error.key));
    } catch (e) {
      emit(CreatePayrollMonthlyError('Error inesperado: $e'));
    }
  }
}
