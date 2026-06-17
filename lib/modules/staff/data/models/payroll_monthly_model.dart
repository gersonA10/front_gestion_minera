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
    super.paidAmount,
    required super.paymentStatus,
    required super.currency,
  });

  factory PayrollMonthlyModel.fromJson(Map<String, dynamic> json) {
    return PayrollMonthlyModel(
      payrollId: json['payroll_id'] ?? '',
      employeeId: json['employee_id'] ?? '',
      fullName: json['full_name'] ?? '',
      position: json['position'] ?? '',
      baseSalary: (json['base_salary'] ?? 0).toDouble(),
      totalDeductions: (json['total_deductions'] ?? 0).toDouble(),
      netTotal: (json['net_total'] ?? 0).toDouble(),
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      paymentStatus: json['payment_status'] ?? '',
      currency: json['currency'] ?? '',
    );
  }
}
