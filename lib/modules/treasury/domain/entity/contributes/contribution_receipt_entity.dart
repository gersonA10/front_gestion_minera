class ContributionReceiptEntity {
  final String detailId;
  final String memberName;
  final double amount;
  final String payDate;
  final String referenceCode;

  const ContributionReceiptEntity({
    required this.detailId,
    required this.memberName,
    required this.amount,
    required this.payDate,
    required this.referenceCode,
  });
}

class ContributionReceiptsResponseEntity {
  final List<ContributionReceiptEntity> receipts;
  final bool hasMore;
  final int totalRecords;

  const ContributionReceiptsResponseEntity({
    required this.receipts,
    required this.hasMore,
    required this.totalRecords,
  });
}
