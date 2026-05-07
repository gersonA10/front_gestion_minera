class TransactionHistoryEntity {
  final String transactionId;
  final double amount;
  final String operationType;
  final DateTime transactionDate;
  final String requestId;
  final String requestCode;
  final String description;
  final String statusKey;
  final String statusLabel;

  TransactionHistoryEntity({
    required this.transactionId,
    required this.amount,
    required this.operationType,
    required this.transactionDate,
    required this.requestId,
    required this.requestCode,
    required this.description,
    required this.statusKey,
    required this.statusLabel,
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
