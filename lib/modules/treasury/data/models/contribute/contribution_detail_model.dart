import '../../../domain/entity/contributes/contribution_detail_entity.dart';

class ContributionDetailHeaderMetricsModel
    extends ContributionDetailHeaderMetricsEntity {
  const ContributionDetailHeaderMetricsModel({
    required super.reason,
    required super.amountPerMember,
    required super.totalGoal,
    required super.actualCollected,
    required super.pendingAmount,
  });

  factory ContributionDetailHeaderMetricsModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      ContributionDetailHeaderMetricsModel(
        reason: json['reason'] as String,
        amountPerMember: (json['amount_per_member'] as num).toDouble(),
        totalGoal: (json['total_goal'] as num).toDouble(),
        actualCollected: (json['actual_collected'] as num).toDouble(),
        pendingAmount: (json['pending_amount'] as num).toDouble(),
      );
}

class ContributionDetailMemberModel extends ContributionDetailMemberEntity {
  const ContributionDetailMemberModel({
    required super.detailId,
    required super.memberId,
    required super.fullName,
    required super.identification,
    required super.amountToPay,
    required super.status,
  });

  factory ContributionDetailMemberModel.fromJson(Map<String, dynamic> json) =>
      ContributionDetailMemberModel(
        detailId: json['detail_id'] as String,
        memberId: json['member_id'] as String,
        fullName: json['full_name'] as String,
        identification: json['identification'] as String,
        amountToPay: (json['amount_to_pay'] as num).toDouble(),
        status: json['status'] as String,
      );
}
