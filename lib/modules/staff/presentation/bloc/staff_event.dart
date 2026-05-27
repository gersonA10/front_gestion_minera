part of 'staff_bloc.dart';

abstract class StaffEvent {}

class GetEmployeesEvent extends StaffEvent {
  final String? search;
  final String? department;
  final String? status;
  final int page;
  final int limit;

  GetEmployeesEvent({
    this.search,
    this.department,
    this.status,
    this.page = 1,
    this.limit = 5,
  });
}

class LoadMoreEmployeesEvent extends StaffEvent {}

class RefreshEmployeesEvent extends StaffEvent {}

class GetEmployeeProfileEvent extends StaffEvent {
  final String employeeId;
  GetEmployeeProfileEvent(this.employeeId);
}

class CreatePayrollMonthlyEvent extends StaffEvent {
  final CreatePayrollMonthlyEntity payroll;

  CreatePayrollMonthlyEvent({required this.payroll});
}

class GetEmployeePayrollEvent extends StaffEvent {}

class RegisterEmployeesEvent extends StaffEvent {
  final RegisterEmployeesEntity employeed;

  RegisterEmployeesEvent({required this.employeed});
}

class GetAttendanceIngresoEvent extends StaffEvent {}

class GetAttendanceEnPlantaEvent extends StaffEvent {}

class GetAttendanceFinalizadoEvent extends StaffEvent {
  final String date;
  GetAttendanceFinalizadoEvent({required this.date});
}

class RegisterCheckInEmployeeEvent extends StaffEvent {
  final EmployeeCheckInEntity checkIn;

  RegisterCheckInEmployeeEvent({required this.checkIn});
}


