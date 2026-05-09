import 'package:front_gestion_minera/modules/camp/domain/entity/entity.dart';

class CloseRequestResultModel extends CloseRequestResultEntity {
  const CloseRequestResultModel({
    required super.requestId,
    required super.globalStatus,
    required super.statusLabel,
    required super.finalAmount,
    required super.requestedAmount,
    required super.differenceAmount,
    required super.differenceType,
    super.closedAt,
  });

  factory CloseRequestResultModel.fromJson(Map<String, dynamic> json) {
    return CloseRequestResultModel(
      requestId: json['request_id'] as String? ?? '',
      globalStatus: json['global_status'] as String? ?? '',
      statusLabel: json['status_label'] as String? ?? '',
      finalAmount: (json['final_amount'] as num?)?.toDouble() ?? 0.0,
      requestedAmount: (json['requested_amount'] as num?)?.toDouble() ?? 0.0,
      differenceAmount: (json['difference_amount'] as num?)?.toDouble() ?? 0.0,
      differenceType: json['difference_type'] as String? ?? '',
      closedAt: json['closed_at'] != null
          ? DateTime.tryParse(json['closed_at'] as String)
          : null,
    );
  }
}
