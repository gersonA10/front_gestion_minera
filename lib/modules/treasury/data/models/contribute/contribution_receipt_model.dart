import '../../../domain/entity/contributes/contribution_receipt_entity.dart';

class ContributionReceiptModel extends ContributionReceiptEntity {
  const ContributionReceiptModel({
    required super.detailId,
    required super.memberName,
    required super.amount,
    required super.payDate,
    required super.referenceCode,
  });

  factory ContributionReceiptModel.fromJson(Map<String, dynamic> json) =>
      ContributionReceiptModel(
        detailId: json['detail_id'] as String,
        memberName: json['member_name'] as String,
        amount: (json['amount'] as num).toDouble(),
        payDate: json['pay_date'] as String,
        referenceCode: json['reference_code'] as String,
      );
}
