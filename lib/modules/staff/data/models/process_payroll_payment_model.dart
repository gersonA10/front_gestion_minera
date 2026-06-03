import '../../domain/entity/process_payroll_payment_entity.dart';

class ProcessPayrollPaymentModel
    extends ProcessPayrollPaymentEntity {
  ProcessPayrollPaymentModel({
    required super.payrollId,
    required super.paymentStatus,
    required super.paidAt,
    super.receiptPdfUrl,
  });

  factory ProcessPayrollPaymentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProcessPayrollPaymentModel(
      payrollId: json['payroll_id'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      paidAt: json['paid_at'] ?? '',
      receiptPdfUrl: json['receipt_pdf_url'],
    );
  }
}