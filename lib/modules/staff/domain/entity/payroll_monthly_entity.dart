class PayrollMonthlyEntity {
  final String payrollId;
  final String employeeId;
  final String fullName;
  final String position;
  final double baseSalary;
  final double totalDeductions;
  final double netTotal;
  final String paymentStatus;
  final String currency;

  PayrollMonthlyEntity({
    required this.payrollId,
    required this.employeeId,
    required this.fullName,
    required this.position,
    required this.baseSalary,
    required this.totalDeductions,
    required this.netTotal,
    required this.paymentStatus,
    required this.currency,
  });
}
