
class PaymentHistoryItemEntity {
  final String transactionId;
  final String? description;
  final DateTime fecha;
  final double monto;
  final String operationType;
  final String destinoDinero;

  const PaymentHistoryItemEntity({
    required this.transactionId,
    required this.description,
    required this.fecha,
    required this.monto,
    required this.operationType,
    required this.destinoDinero,
  });
}

class PaymentHistorySummaryEntity {
  final double totalMontoHoy;
  final double totalIngresosHoy;
  final int totalTransaccionesHoy;

  const PaymentHistorySummaryEntity({
    required this.totalMontoHoy,
    required this.totalIngresosHoy,
    required this.totalTransaccionesHoy,
  });
}

class PaymentHistoryResponseEntity {
  final PaymentHistorySummaryEntity summary;
  final List<PaymentHistoryItemEntity> items;
  final bool hasMoreData;
  final int totalRecords;

  const PaymentHistoryResponseEntity({
    required this.summary,
    required this.items,
    required this.hasMoreData,
    required this.totalRecords,
  });
}
