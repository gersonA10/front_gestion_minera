class LoanHistoryResponseEntity {
  final bool success;
  final String message;
  final List<LoanHistoryDataEntity> data;

  LoanHistoryResponseEntity({
    required this.success,
    required this.message,
    required this.data,
  });
}

class LoanHistoryDataEntity {
  final String loanId;
  final String loanType;
  final String amountOrQuantity;
  final String description;
  final String fileUrl;
  final String status;
  final DateTime createdAt;

  LoanHistoryDataEntity({
    required this.loanId,
    required this.loanType,
    required this.amountOrQuantity,
    required this.description,
    required this.fileUrl,
    required this.status,
    required this.createdAt,
  });
}
