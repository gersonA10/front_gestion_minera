class PayrollMonthlyEntity {
  final String payrollId;
  final String employeeId;
  final String fullName;
  final String position;
  final double baseSalary;
  final double totalDeductions;
  final double netTotal;
  final double paidAmount;
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
    this.paidAmount = 0,
    required this.paymentStatus,
    required this.currency,
  });

  /// Neto a recibir = salario base − deducciones (el adelanto ya descuenta).
  double get netToReceive => baseSalary - totalDeductions;

  /// Lo que falta por pagar.
  double get remaining {
    final r = netToReceive - paidAmount;
    return r < 0 ? 0 : r;
  }
}
