import '../../domain/entity/request_history_entity.dart';

class RequestHistoryModel extends RequestHistoryEntity {
  RequestHistoryModel({
    required super.id,
    required super.area,
    required super.amount,
    required super.reason,
    required super.receiptUrl,
    required super.status,
    required super.date,
    super.rejectionReason
  });

  factory RequestHistoryModel.fromJson(Map<String, dynamic> json) {
    return RequestHistoryModel(
      id: json['request_id'] ?? '',
      area: json['area'] ?? '',
      amount: double.tryParse(json['monto']?.toString() ?? '0') ?? 0.0,
      reason: json['motivo'] ?? '',
      receiptUrl: json['comprobante'] ?? '',
      status: json['estado'] ?? 'Desconocido',
      rejectionReason: json['motivo_rechazo'],
      date: DateTime.tryParse(json['fecha_registro'] ?? '') ?? DateTime.now(),
    );
  }

  RequestHistoryEntity toEntity() {
    return RequestHistoryEntity(
      id: id,
      area: area,
      amount: amount,
      reason: reason,
      receiptUrl: receiptUrl,
      status: status,
      rejectionReason: rejectionReason,
      date: date,
    );
  }
}