class DistributionHistoryItemEntity {
  final String distributionId;
  final String period;
  final String registeredDate;
  final String status;
  final double registeredAmount;
  final double amountPaid;
  final double amountDue;
  final int progressPct;

  const DistributionHistoryItemEntity({
    required this.distributionId,
    required this.period,
    required this.registeredDate,
    required this.status,
    required this.registeredAmount,
    required this.amountPaid,
    required this.amountDue,
    required this.progressPct,
  });
}

class DistributionHistoryResponseEntity {
  final List<DistributionHistoryItemEntity> items;
  final bool hasMore;
  final int totalRecords;

  const DistributionHistoryResponseEntity({
    required this.items,
    required this.hasMore,
    required this.totalRecords,
  });
}
