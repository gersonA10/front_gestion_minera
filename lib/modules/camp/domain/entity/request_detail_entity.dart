class RequestDetailEntity {
  final String requestId;
  final String displayCode;
  final String description;
  final double requestedAmount;
  final double finalAmount;
  final double differenceAmount;
  final String differenceType;
  final String globalStatus;
  final String statusLabel;
  final String? requiredAction;
  final String? evidenceUrl;
  final String? rejectReason;
  final String requesterName;
  final DateTime createdAt;
  final DateTime? closedAt;
  final List<RequestTimelineStepEntity> timeline;

  RequestDetailEntity({
    required this.requestId,
    required this.displayCode,
    required this.description,
    required this.requestedAmount,
    required this.finalAmount,
    required this.differenceAmount,
    required this.differenceType,
    required this.globalStatus,
    required this.statusLabel,
    this.requiredAction,
    this.evidenceUrl,
    this.rejectReason,
    required this.requesterName,
    required this.createdAt,
    this.closedAt,
    required this.timeline,
  });
}

class RequestTimelineStepEntity {
  final int step;
  final String key;
  final String title;
  final String description;
  final String status;
  final DateTime? date;

  RequestTimelineStepEntity({
    required this.step,
    required this.key,
    required this.title,
    required this.description,
    required this.status,
    this.date,
  });
}
