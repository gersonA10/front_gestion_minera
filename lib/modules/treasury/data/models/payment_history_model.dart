
import '../../domain/entity/payment_history_entity.dart';

class PaymentHistoryItemModel extends PaymentHistoryItemEntity {
  const PaymentHistoryItemModel({
    required super.transactionId,
    required super.description,
    required super.fecha,
    required super.monto,
    required super.operationType,
    required super.destinoDinero,
  });

  factory PaymentHistoryItemModel.fromJson(Map<String, dynamic> json) =>
      PaymentHistoryItemModel(
        transactionId: json['transaction_id'] as String,
        description: json['description'] as String?,
        fecha: DateTime.parse(json['fecha'] as String),
        monto: double.parse(json['monto'].toString()),
        operationType: json['operation_type'] as String,
        destinoDinero: json['destino_dinero'] as String,
      );
}

class PaymentHistorySummaryModel extends PaymentHistorySummaryEntity {
  const PaymentHistorySummaryModel({
    required super.totalMontoHoy,
    required super.totalTransaccionesHoy,
  });

  factory PaymentHistorySummaryModel.fromJson(Map<String, dynamic> json) =>
      PaymentHistorySummaryModel(
        totalMontoHoy: (json['total_monto_hoy'] as num).toDouble(),
        totalTransaccionesHoy: json['total_transacciones_hoy'] as int,
      );
}
