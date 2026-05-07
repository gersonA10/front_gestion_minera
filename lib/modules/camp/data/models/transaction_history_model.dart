import 'package:front_gestion_minera/modules/camp/domain/entity/entity.dart';

class TransactionHistoryModel extends TransactionHistoryEntity {
  TransactionHistoryModel({
    required super.transactionId,
    required super.amount,
    required super.operationType,
    required super.transactionDate,
    required super.requestId,
    required super.requestCode,
    required super.description,
    required super.statusKey,
    required super.statusLabel,
  });

  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryModel(
      transactionId: json['transaction_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      operationType: json['operation_type'] as String? ?? '',
      transactionDate: DateTime.tryParse(json['transaction_date'] as String? ?? '') ?? DateTime.now(),
      requestId: json['request_id'] as String? ?? '',
      requestCode: json['request_code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      statusKey: json['status_key'] as String? ?? '',
      statusLabel: json['status_label'] as String? ?? '',
    );
  }
}
