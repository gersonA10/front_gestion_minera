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

class UpdateEmployeeProfileEvent extends StaffEvent {
  final String employeeId;
  final String? status;
  final String? shiftType;
  final String? department;
  final double? baseMonthlySalary;
  UpdateEmployeeProfileEvent(
    this.employeeId, {
    this.status,
    this.shiftType,
    this.department,
    this.baseMonthlySalary,
  });
}

class GetEgresoDetailEvent extends StaffEvent {
  final String requestId;
  GetEgresoDetailEvent(this.requestId);
}

class GetEmployeeBalanceEvent extends StaffEvent {
  final String employeeId;
  GetEmployeeBalanceEvent(this.employeeId);
}

class GetPersonnelCashEvent extends StaffEvent {}

class GetCashBalanceEvent extends StaffEvent {}

class PayPayrollFromCashEvent extends StaffEvent {
  final String payrollId;
  PayPayrollFromCashEvent(this.payrollId);
}

class RequestEmployeePaymentEvent extends StaffEvent {
  final String employeeId;
  final String employeeName;
  final String requestType; // 'ADELANTO' | 'SALDO'
  final double amount;
  final String justification;
  final String imagePath;
  RequestEmployeePaymentEvent({
    required this.employeeId,
    required this.employeeName,
    required this.requestType,
    required this.amount,
    required this.justification,
    required this.imagePath,
  });
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

class CheckOutEmployeeEvent extends StaffEvent {
  final String attendanceId;
  final EmployeeCheckOutRequestEntity request;

  CheckOutEmployeeEvent({required this.attendanceId, required this.request});
}

class RegisterCheckInEmployeeEvent extends StaffEvent {
  final EmployeeCheckInEntity checkIn;

  RegisterCheckInEmployeeEvent({required this.checkIn});
}

class GetDetailAssistanceEmployeeEvent extends StaffEvent {
  final String employeeId;

  GetDetailAssistanceEmployeeEvent({required this.employeeId});
}

class GetAttendanceReportEvent extends StaffEvent {
  final String employeeId;

  /// 'weekly' | 'monthly'. Ignorado si se envía [from]/[to].
  final String period;
  final String? ref;
  final String? from;
  final String? to;

  GetAttendanceReportEvent({
    required this.employeeId,
    this.period = 'weekly',
    this.ref,
    this.from,
    this.to,
  });
}

class GetPayrollMonthlyListEvent extends StaffEvent {
  final int month;
  final int year;

  GetPayrollMonthlyListEvent({required this.month, required this.year});
}

class GetHistoryRecordExpenditureEvent extends StaffEvent {
  final String year;
  final String state;
  final bool isRefresh;

  GetHistoryRecordExpenditureEvent({
    required this.year,
    required this.state,
    this.isRefresh = true,
  });
}

class LoadMoreHistoryRecordExpenditureEvent extends StaffEvent {}

class GetPayrollHistoryEvent extends StaffEvent {
  final int year;
  final int page;
  final int limit;

  GetPayrollHistoryEvent({required this.year, this.page = 1, this.limit = 10});
}

class ProcessPayrollPaymentEvent extends StaffEvent {
  final String payrollId;
  final String idempotencyKey;
  final String comprobantePath;
  final double? amount;

  ProcessPayrollPaymentEvent({
    required this.payrollId,
    required this.idempotencyKey,
    required this.comprobantePath,
    this.amount,
  });
}
