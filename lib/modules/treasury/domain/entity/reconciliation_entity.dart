/// Item de la lista de reposiciones pendientes (solicitudes de Campamento
/// cerradas con una diferencia que Hacienda debe conciliar).
class ReconciliationItemEntity {
  final String requestId;
  final String description;
  final String solicitante;
  final String? rol;
  final double requestedAmount;
  final double finalAmount;
  final double differenceAmount; // final - solicitado (con signo)
  final String differenceType; // 'COMPENSACION' | 'DEVOLUCION' | 'EXACTO'
  final DateTime? closedAt;
  final String? evidenciaUrl;

  ReconciliationItemEntity({
    required this.requestId,
    required this.description,
    required this.solicitante,
    this.rol,
    required this.requestedAmount,
    required this.finalAmount,
    required this.differenceAmount,
    required this.differenceType,
    this.closedAt,
    this.evidenciaUrl,
  });
}

class ReconciliationListResponseEntity {
  final List<ReconciliationItemEntity> items;
  final bool hasMoreData;
  final int totalRecords;

  ReconciliationListResponseEntity({
    required this.items,
    required this.hasMoreData,
    required this.totalRecords,
  });
}

/// Resultado de ejecutar una reposición.
class ExecuteReconciliationResultEntity {
  final String? referenceCode;
  final String differenceType;
  final double amount;

  ExecuteReconciliationResultEntity({
    required this.referenceCode,
    required this.differenceType,
    required this.amount,
  });
}
