import 'package:front_gestion_minera/modules/camp/domain/entity/entity.dart';

class TransactionHistoryModel extends TransactionHistoryEntity {
  TransactionHistoryModel({
    required super.requestId,
    required super.requestCode,
    required super.description,
    required super.globalStatus,
    required super.statusLabel,
    required super.requestedAmount,
    super.finalAmount,
    super.transactionId,
    super.transactionAmount,
    super.transactionDate,
    required super.createdAt,
    super.closedAt,
    super.rejectReason,
  });

  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryModel(
      requestId: json['request_id'] as String? ?? '',
      requestCode: json['request_code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      globalStatus: json['global_status'] as String? ?? '',
      statusLabel: json['status_label'] as String? ?? '',
      requestedAmount: (json['requested_amount'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (json['final_amount'] as num?)?.toDouble(),
      transactionId: json['transaction_id'] as String?,
      transactionAmount: (json['transaction_amount'] as num?)?.toDouble(),
      transactionDate: json['transaction_date'] != null
          ? DateTime.tryParse(json['transaction_date'] as String)
          : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      closedAt: json['closed_at'] != null
          ? DateTime.tryParse(json['closed_at'] as String)
          : null,
      rejectReason: json['reject_reason'] as String?,
    );
  }
}
