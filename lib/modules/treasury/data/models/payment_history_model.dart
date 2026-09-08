
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
    required super.totalIngresosHoy,
    required super.totalTransaccionesHoy,
  });

  // pg puede serializar SUM/COUNT como String y los backends viejos pueden
  // omitir campos: todo el summary se parsea de forma tolerante.
  factory PaymentHistorySummaryModel.fromJson(Map<String, dynamic> json) =>
      PaymentHistorySummaryModel(
        totalMontoHoy: _asDouble(json['total_monto_hoy']),
        totalIngresosHoy: _asDouble(json['total_ingresos_hoy']),
        totalTransaccionesHoy: _asDouble(json['total_transacciones_hoy']).toInt(),
      );

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
