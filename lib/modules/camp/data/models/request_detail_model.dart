import '../../domain/entity/entity.dart';

class RequestDetailModel extends RequestDetailEntity {
  RequestDetailModel({
    required super.requestId,
    required super.displayCode,
    required super.description,
    required super.requestedAmount,
    required super.finalAmount,
    required super.differenceAmount,
    required super.differenceType,
    required super.globalStatus,
    required super.statusLabel,
    super.requiredAction,
    super.evidenceUrl,
    super.rejectReason,
    required super.requesterName,
    required super.createdAt,
    super.closedAt,
    required super.timeline,
  });

  factory RequestDetailModel.fromJson(Map<String, dynamic> json) {
    return RequestDetailModel(
      requestId: json['request_id'] as String? ?? '',
      displayCode: json['display_code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      requestedAmount: (json['requested_amount'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (json['final_amount'] as num?)?.toDouble() ?? 0.0,
      differenceAmount: (json['difference_amount'] as num?)?.toDouble() ?? 0.0,
      differenceType: json['difference_type'] as String? ?? '',
      globalStatus: json['global_status'] as String? ?? '',
      statusLabel: json['status_label'] as String? ?? '',
      requiredAction: json['required_action'] as String?,
      evidenceUrl: json['evidence_url'] as String?,
      rejectReason: json['reject_reason'] as String?,
      requesterName: json['requester_name'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      closedAt: json['closed_at'] != null
          ? DateTime.tryParse(json['closed_at'] as String)
          : null,
      timeline: (json['timeline'] as List? ?? [])
          .map((e) => RequestTimelineStepModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RequestTimelineStepModel extends RequestTimelineStepEntity {
  RequestTimelineStepModel({
    required super.step,
    required super.key,
    required super.title,
    required super.description,
    required super.status,
    super.date,
  });

  factory RequestTimelineStepModel.fromJson(Map<String, dynamic> json) {
    return RequestTimelineStepModel(
      step: json['step'] as int? ?? 0,
      key: json['key'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      date: json['date'] != null ? DateTime.tryParse(json['date'] as String) : null,
    );
  }
}
