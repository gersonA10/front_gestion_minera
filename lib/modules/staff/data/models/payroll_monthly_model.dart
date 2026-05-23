import '../../domain/entity/entity.dart';

class PayrollMonthlyModel extends PayrollMonthlyEntity {
  PayrollMonthlyModel({
    required super.payrollId,
    required super.employeeId,
    required super.fullName,
    required super.position,
    required super.baseSalary,
    required super.totalDeductions,
    required super.netTotal,
    required super.paymentStatus,
    required super.currency,
  });

  factory PayrollMonthlyModel.fromJson(Map<String, dynamic> json) {
    return PayrollMonthlyModel(
      payrollId: json['payroll_id'],
      employeeId: json['employee_id'],
      fullName: json['full_name'],
      position: json['position'],
      baseSalary: json['base_salary'],
      totalDeductions: json['total_deductions'],
      netTotal: json['net_total'],
      paymentStatus: json['payment_status'],
      currency: json['currency'],
    );
  }
}
