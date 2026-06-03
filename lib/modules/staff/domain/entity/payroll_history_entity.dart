class PayrollHistoryEntity {
  final String period;
  final String payrollType;
  final double totalAmount;
  final String paymentDate;
  final String status;

  const PayrollHistoryEntity({
    required this.period,
    required this.payrollType,
    required this.totalAmount,
    required this.paymentDate,
    required this.status,
  });
}