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

// Attendance Ingreso
class AttendanceIngresoLoading extends StaffState {}

class AttendanceIngresoLoaded extends StaffState {
  final List<AttendanceIngresoEntity> employees;
  AttendanceIngresoLoaded(this.employees);
}

class AttendanceIngresoError extends StaffState {
  final String message;
  AttendanceIngresoError(this.message);
}

// Attendance En Planta
class AttendanceEnPlantaLoading extends StaffState {}

class AttendanceEnPlantaLoaded extends StaffState {
  final List<AttendanceEnPlantaEntity> employees;
  AttendanceEnPlantaLoaded(this.employees);
}

class AttendanceEnPlantaError extends StaffState {
  final String message;
  AttendanceEnPlantaError(this.message);
}

// Attendance Finalizado
class AttendanceFinalizadoLoading extends StaffState {}

class AttendanceFinalizadoLoaded extends StaffState {
  final List<AttendanceFinalizadoEntity> employees;
  AttendanceFinalizadoLoaded(this.employees);
}

class AttendanceFinalizadoError extends StaffState {
  final String message;
  AttendanceFinalizadoError(this.message);
}

class CheckOutEmployeeLoading extends StaffState {}

class CheckOutEmployeeSuccess extends StaffState {
  final EmployeeCheckOutResponseEntity data;
  CheckOutEmployeeSuccess(this.data);
}

class CheckOutEmployeeError extends StaffState {
  final String message;
  CheckOutEmployeeError(this.message);
}

class CheckInEmployeeLoading extends StaffState {}

class CheckInEmployeeSuccess extends StaffState {}

class CheckInEmployeeError extends StaffState {
  final String message;
  CheckInEmployeeError(this.message);
}

class DetailAssistanceEmployeeLoading extends StaffState {}

class DetailAssistanceEmployeeLoaded extends StaffState {
  final EmployeeDetailAssistanceModel employee;

  DetailAssistanceEmployeeLoaded({required this.employee});
}

class DetailAssistanceEmployeeError extends StaffState {
  final String message;
  DetailAssistanceEmployeeError(this.message);
}

class PayrollMonthlyLoading extends StaffState {}

class PayrollMonthlyLoaded extends StaffState {
  final List<PayrollMonthlyEntity> payrolls;
  final double totalPayroll;
  final double totalPaid;
  final double totalPending;
  PayrollMonthlyLoaded({
    required this.payrolls,
    required this.totalPayroll,
    required this.totalPaid,
    required this.totalPending,
  });
}

class PayrollMonthlyError extends StaffState {
  final String message;

  PayrollMonthlyError(this.message);
}

class HistoryRecordExpenditureLoading extends StaffState {}

class HistoryRecordExpenditureLoaded extends StaffState {
  final List<HistoryExpenditureEntity> items;
  final double totalExpenses;
  final bool hasMore;
  final int total;
  HistoryRecordExpenditureLoaded({
    required this.items,
    required this.hasMore,
    required this.total,
    required this.totalExpenses,
  });
}

class HistoryRecordExpenditureError extends StaffState {
  final String message;
  HistoryRecordExpenditureError(this.message);
}

class PayrollHistoryLoading extends StaffState {}

class PayrollHistoryLoaded extends StaffState {
  final PayrollHistoryResponseModel history;
  PayrollHistoryLoaded({required this.history});
}

class PayrollHistoryError extends StaffState {
  final String message;
  PayrollHistoryError({required this.message});
}

class ProcessPayrollPaymentLoading extends StaffState {}

class ProcessPayrollPaymentSuccess extends StaffState {
  final ProcessPayrollPaymentEntity payment;
  ProcessPayrollPaymentSuccess(this.payment);
}

class ProcessPayrollPaymentError extends StaffState {
  final String message;
  ProcessPayrollPaymentError(this.message);
}
