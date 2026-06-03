class ProcessPayrollPaymentEntity {
  final String payrollId;
  final String paymentStatus;
  final String paidAt;
  final String? receiptPdfUrl;

  ProcessPayrollPaymentEntity({
    required this.payrollId,
    required this.paymentStatus,
    required this.paidAt,
    this.receiptPdfUrl,
  });
}