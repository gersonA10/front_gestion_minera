class CashMovementEntity {
  final String transactionId;

  /// 'INCOME' (ingreso de Hacienda) | 'EXPENSE' (pago a trabajador)
  final String operationType;
  final double amount;
  final String description;
  final String? referenceCode;
  final String createdAt;

  const CashMovementEntity({
    required this.transactionId,
    required this.operationType,
    required this.amount,
    required this.description,
    required this.referenceCode,
    required this.createdAt,
  });

  bool get isIncome => operationType.toUpperCase() == 'INCOME';
}

class CashPayableEntity {
  final String payrollId;
  final String employeeId;
  final String fullName;
  final int month;
  final int year;
  final double net;
  final bool isOverdue;

  const CashPayableEntity({
    required this.payrollId,
    required this.employeeId,
    required this.fullName,
    required this.month,
    required this.year,
    required this.net,
    required this.isOverdue,
  });
}
