class CloseRequestResultEntity {
  final String requestId;
  final String globalStatus;
  final String statusLabel;
  final double finalAmount;
  final double requestedAmount;
  final double differenceAmount;
  final String differenceType;
  final DateTime? closedAt;

  const CloseRequestResultEntity({
    required this.requestId,
    required this.globalStatus,
    required this.statusLabel,
    required this.finalAmount,
    required this.requestedAmount,
    required this.differenceAmount,
    required this.differenceType,
    this.closedAt,
  });
}
