class RequestHistoryEntity {
  final String id;
  final String area;
  final double amount;
  final String reason;
  final String receiptUrl;
  final String status;
  final String? rejectionReason;
  final DateTime date;

  RequestHistoryEntity({
    required this.id,
    required this.area,
    required this.amount,
    required this.reason,
    required this.receiptUrl,
    required this.status,
    required this.date,
    this.rejectionReason
  });
}

class PaginatedHistoryEntity {
  final List<RequestHistoryEntity> items;
  final bool hasMoreData;

  PaginatedHistoryEntity({required this.items, required this.hasMoreData});
}