class DistributionDetailHeaderEntity {
  final String period;
  final String status;
  final double totalRegisteredAmount;
  final double totalPaidAmount;
  final double totalPendingAmount;
  final int totalMembers;
  final int paidMembers;
  final int pendingMembers;

  const DistributionDetailHeaderEntity({
    required this.period,
    required this.status,
    required this.totalRegisteredAmount,
    required this.totalPaidAmount,
    required this.totalPendingAmount,
    required this.totalMembers,
    required this.paidMembers,
    required this.pendingMembers,
  });
}

class DistributionDetailMemberEntity {
  final String detailId;
  final String memberId;
  final String fullName;
  final double assignedAmount;
  final String status;
  final String? paymentDate;
  final String? transactionId;

  const DistributionDetailMemberEntity({
    required this.detailId,
    required this.memberId,
    required this.fullName,
    required this.assignedAmount,
    required this.status,
    this.paymentDate,
    this.transactionId,
  });
}

class DistributionDetailResponseEntity {
  final DistributionDetailHeaderEntity header;
  final List<DistributionDetailMemberEntity> membersList;
  final bool hasMore;
  final int totalRecords;

  const DistributionDetailResponseEntity({
    required this.header,
    required this.membersList,
    required this.hasMore,
    required this.totalRecords,
  });
}
