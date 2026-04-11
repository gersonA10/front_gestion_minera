class ContributeItemEntity {
  final String contributionId;
  final String reason;
  final String period;
  final String creationDate;
  final double collectionGoal;
  final double individualAmount;
  final int totalMembers;
  final int progressPercentage;

  const ContributeItemEntity({
    required this.contributionId,
    required this.reason,
    required this.period,
    required this.creationDate,
    required this.collectionGoal,
    required this.individualAmount,
    required this.totalMembers,
    required this.progressPercentage,
  });
}

class ContributeMetricsEntity {
  final double totalCollected;
  final double totalPending;
  final String? totalSocio;

  const ContributeMetricsEntity({
    required this.totalCollected,
    required this.totalPending,
    required this.totalSocio,
  });
}

class ContributionsResponseEntity {
  final List<ContributeItemEntity> items;
  final ContributeMetricsEntity metrics;
  final bool hasMore;
  final int totalRecords;

  const ContributionsResponseEntity({
    required this.items,
    required this.metrics,
    required this.hasMore,
    required this.totalRecords,
  });
}
