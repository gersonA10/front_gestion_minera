import '../../../domain/entity/distribute/distribution_detail_entity.dart';

class DistributionDetailHeaderModel extends DistributionDetailHeaderEntity {
  const DistributionDetailHeaderModel({
    required super.period,
    required super.status,
    required super.totalRegisteredAmount,
    required super.totalPaidAmount,
    required super.totalPendingAmount,
    required super.totalMembers,
    required super.paidMembers,
    required super.pendingMembers,
  });

  factory DistributionDetailHeaderModel.fromJson(Map<String, dynamic> json) =>
      DistributionDetailHeaderModel(
        period: json['period'] as String,
        status: json['status'] as String,
        totalRegisteredAmount:
            (json['total_registered_amount'] as num).toDouble(),
        totalPaidAmount: (json['total_paid_amount'] as num).toDouble(),
        totalPendingAmount: (json['total_pending_amount'] as num).toDouble(),
        totalMembers: json['total_members'] as int,
        paidMembers: json['paid_members'] as int,
        pendingMembers: json['pending_members'] as int,
      );
}

class DistributionDetailMemberModel extends DistributionDetailMemberEntity {
  const DistributionDetailMemberModel({
    required super.detailId,
    required super.memberId,
    required super.fullName,
    required super.assignedAmount,
    required super.status,
    super.paymentDate,
    super.transactionId,
  });

  factory DistributionDetailMemberModel.fromJson(Map<String, dynamic> json) =>
      DistributionDetailMemberModel(
        detailId: json['detail_id'] as String,
        memberId: json['member_id'] as String,
        fullName: json['full_name'] as String,
        assignedAmount: (json['assigned_amount'] as num).toDouble(),
        status: json['status'] as String,
        paymentDate: json['payment_date'] as String?,
        transactionId: json['transaction_id'] as String?,
      );
}
