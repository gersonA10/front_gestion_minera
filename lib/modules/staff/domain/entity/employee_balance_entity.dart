class EmployeeBalanceEntity {
  final double totalPendingAmount;
  final int totalPendingMonths;

  /// Atrasado = nóminas pendientes de ciclos anteriores al actual.
  final double overdueAmount;
  final int overdueMonths;

  const EmployeeBalanceEntity({
    required this.totalPendingAmount,
    required this.totalPendingMonths,
    required this.overdueAmount,
    required this.overdueMonths,
  });

  bool get hasOverdue => overdueAmount > 0;
}
