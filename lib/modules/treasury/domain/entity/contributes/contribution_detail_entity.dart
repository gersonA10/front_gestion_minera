class ContributionDetailHeaderMetricsEntity {
  final String reason;
  final double amountPerMember;
  final double totalGoal;
  final double actualCollected;
  final double pendingAmount;

  const ContributionDetailHeaderMetricsEntity({
    required this.reason,
    required this.amountPerMember,
    required this.totalGoal,
    required this.actualCollected,
    required this.pendingAmount,
  });
}

class ContributionDetailMemberEntity {
  final String detailId;
  final String memberId;
  final String fullName;
  final String identification;
  final double amountToPay;
  final String status;

  const ContributionDetailMemberEntity({
    required this.detailId,
    required this.memberId,
    required this.fullName,
    required this.identification,
    required this.amountToPay,
    required this.status,
  });
}

class ContributionDetailResponseEntity {
  final ContributionDetailHeaderMetricsEntity headerMetrics;
  final List<ContributionDetailMemberEntity> membersList;
  final bool hasMore;
  final int totalRecords;

  const ContributionDetailResponseEntity({
    required this.headerMetrics,
    required this.membersList,
    required this.hasMore,
    required this.totalRecords,
  });
}
