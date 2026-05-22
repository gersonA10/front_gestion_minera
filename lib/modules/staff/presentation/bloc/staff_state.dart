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

class EmployeesError extends StaffState {
  final String message;

  EmployeesError(this.message);
}
