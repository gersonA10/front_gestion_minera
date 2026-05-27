part of 'staff_bloc.dart';

abstract class StaffState {}

class StaffInitial extends StaffState {}

class EmployeesLoading extends StaffState {}

class EmployeesPageLoading extends StaffState {
  final EmployeesLoaded previousState;
  EmployeesPageLoading(this.previousState);
}

class EmployeesLoaded extends StaffState {
  final List<EmployeeEntity> employees;
  final bool hasMore;
  final int total;
  final int currentPage;
  final int totalPages;
  final String? currentSearch;
  final String? currentDepartment;
  final String? currentStatus;

  EmployeesLoaded({
    required this.employees,
    required this.hasMore,
    required this.total,
    required this.currentPage,
    required this.totalPages,
    this.currentSearch,
    this.currentDepartment,
    this.currentStatus,
  });

  EmployeesLoaded copyWith({
    List<EmployeeEntity>? employees,
    bool? hasMore,
    int? total,
    int? currentPage,
    int? totalPages,
    String? currentSearch,
    String? currentDepartment,
    String? currentStatus,
  }) {
    return EmployeesLoaded(
      employees: employees ?? this.employees,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      currentSearch: currentSearch ?? this.currentSearch,
      currentDepartment: currentDepartment ?? this.currentDepartment,
      currentStatus: currentStatus ?? this.currentStatus,
    );
  }
}

class RegisterEmployeesLoading extends StaffState {}

class RegisterEmployeesSuccess extends StaffState {}

class RegisterEmployeesError extends StaffState {
  final String message;
  RegisterEmployeesError(this.message);
}


class EmployeesError extends StaffState {
  final String message;
  EmployeesError(this.message);
}

class EmployeeProfileLoading extends StaffState {}

class EmployeeProfileLoaded extends StaffState {
  final EmployeeEntity employee;
  EmployeeProfileLoaded(this.employee);
}

class EmployeeProfileError extends StaffState {
  final String message;
  EmployeeProfileError(this.message);
}

class CreatePayrollRequestLoading extends StaffState {}

class CreatePayrollRequestSuccess extends StaffState {}

class CreatePayrollRequestError extends StaffState {
  final String message;
  CreatePayrollRequestError(this.message);
}

class GenerateEmployeePayrollLoading extends StaffState {}

class GenerateEmployeePayrollSuccess extends StaffState {
  final int totalEmployee;
  final double totalAmount;
  GenerateEmployeePayrollSuccess({
    required this.totalEmployee,
    required this.totalAmount,
  });
}

class GenerateEmployeePayrollError extends StaffState {
  final String message;
  GenerateEmployeePayrollError(this.message);
}
