import '../../domain/entity/reconciliation_entity.dart';

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

class ReconciliationItemModel {
  static ReconciliationItemEntity fromJson(Map<String, dynamic> json) {
    return ReconciliationItemEntity(
      requestId: json['request_id']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      solicitante: json['solicitante']?.toString() ?? '',
      rol: json['rol']?.toString(),
      requestedAmount: _toDouble(json['requested_amount']),
      finalAmount: _toDouble(json['final_amount']),
      differenceAmount: _toDouble(json['difference_amount']),
      differenceType: json['difference_type']?.toString() ?? 'EXACTO',
      closedAt: json['closed_at'] != null
          ? DateTime.tryParse(json['closed_at'].toString())
          : null,
      evidenciaUrl: json['evidencia_url']?.toString(),
    );
  }
}

class ExecuteReconciliationResponseModel {
  static ExecuteReconciliationResultEntity fromJson(Map<String, dynamic> json) {
    return ExecuteReconciliationResultEntity(
      referenceCode: json['transaction_reference']?.toString(),
      differenceType: json['difference_type']?.toString() ?? 'EXACTO',
      amount: _toDouble(json['amount']),
    );
  }
}
