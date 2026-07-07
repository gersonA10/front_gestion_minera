import '../../../domain/entity/entity.dart';

class ReceiptResponseModel extends ReceiptResponseEneity {

    ReceiptResponseModel({
        required super.memberName,
        required super.identification,
        required super.period,
        required super.paidAmount,
        required super.paymentDate,
        required super.affectedCashbox,
        required super.reference,
        required super.transactionId,
        required super.evidenceUrl,
    });

    factory ReceiptResponseModel.fromJson(Map<String, dynamic> json) => ReceiptResponseModel(
        memberName: json["member_name"],
        identification: json["identification"],
        period: json["period"],
        paidAmount: (json["paid_amount"] as num).toDouble(),
        paymentDate: DateTime.parse(json["payment_date"]),
        affectedCashbox: json["affected_cashbox"],
        reference: json["reference"],
        transactionId: json["transaction_id"],
        evidenceUrl: json["evidence_url"],
    );
}
