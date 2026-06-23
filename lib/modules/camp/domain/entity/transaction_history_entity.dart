class TransactionHistoryEntity {
  final String requestId;
  final String requestCode;
  final String description;
  final String globalStatus;
  final String statusLabel;
  final double requestedAmount;
  final double? finalAmount;
  final String? transactionId;
  final double? transactionAmount;
  final DateTime? transactionDate;
  final DateTime createdAt;
  final DateTime? closedAt;
  final String? rejectReason;

  /// Estado de conciliación (reposición): 'PENDING' | 'RECONCILED' |
  /// 'NOT_REQUIRED' | null.
  final String? reconciliationStatus;

  TransactionHistoryEntity({
    required this.requestId,
    required this.requestCode,
    required this.description,
    required this.globalStatus,
    required this.statusLabel,
    required this.requestedAmount,
    this.finalAmount,
    this.transactionId,
    this.transactionAmount,
    this.transactionDate,
    required this.createdAt,
    this.closedAt,
    this.rejectReason,
    this.reconciliationStatus,
  });
}

class PaginatedTransactionHistoryEntity {
  final List<TransactionHistoryEntity> items;
  final bool hasMore;
  final int totalRecords;

  PaginatedTransactionHistoryEntity({
    required this.items,
    required this.hasMore,
    required this.totalRecords,
  });
}
