class HistoryExpenditureResponseEntity {
  final int page;
  final int limit;
  final int total;
  final bool hasMore;
  final double totalExpenses;
  final List<HistoryExpenditureEntity> items;

  HistoryExpenditureResponseEntity({
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
    required this.totalExpenses,
    required this.items,
  });
}

class HistoryExpenditureEntity {
  final String requestId;
  final String payrollCycle;
  final double totalRequested;
  final double approvedAmount;
  final String requestedDate;
  final String? closedDate;
  final String status;
  final String? rejectReason;

  HistoryExpenditureEntity({
    required this.requestId,
    required this.payrollCycle,
    required this.totalRequested,
    required this.approvedAmount,
    required this.requestedDate,
    required this.closedDate,
    required this.status,
    required this.rejectReason,
  });
}
