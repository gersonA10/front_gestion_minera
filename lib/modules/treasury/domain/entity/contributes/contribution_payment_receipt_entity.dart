class ContributionPaymentReceiptEntity {
  final String receiptStatus;
  final double amountPaid;
  final String reason;
  final String period;
  final DateTime paymentDate;
  final String paidBy;
  final String registeredBy;
  final String transactionId;
  final String observation;

  const ContributionPaymentReceiptEntity({
    required this.receiptStatus,
    required this.amountPaid,
    required this.reason,
    required this.period,
    required this.paymentDate,
    required this.paidBy,
    required this.registeredBy,
    required this.transactionId,
    required this.observation,
  });
}
