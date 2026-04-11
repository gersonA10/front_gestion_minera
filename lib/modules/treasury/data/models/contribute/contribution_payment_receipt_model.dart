import '../../../domain/entity/contributes/contribution_payment_receipt_entity.dart';

class ContributionPaymentReceiptModel extends ContributionPaymentReceiptEntity {
  const ContributionPaymentReceiptModel({
    required super.receiptStatus,
    required super.amountPaid,
    required super.reason,
    required super.period,
    required super.paymentDate,
    required super.paidBy,
    required super.registeredBy,
    required super.transactionId,
    required super.observation,
  });

  factory ContributionPaymentReceiptModel.fromJson(Map<String, dynamic> json) =>
      ContributionPaymentReceiptModel(
        receiptStatus: json['receipt_status'] as String,
        amountPaid: (json['amount_paid'] as num).toDouble(),
        reason: json['reason'] as String,
        period: json['period'] as String,
        paymentDate: DateTime.parse(json['payment_date'] as String),
        paidBy: json['paid_by'] as String,
        registeredBy: json['registered_by'] as String,
        transactionId: json['transaction_id'] as String,
        observation: json['observation'] as String,
      );
}
