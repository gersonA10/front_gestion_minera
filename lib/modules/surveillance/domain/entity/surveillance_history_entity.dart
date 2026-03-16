class SurveillanceHistoryEntity {
  final String requestId;
  final DateTime createdAt;
  final String name;
  final String rol;
  final String description;
  final String amount;
  final String evidencia;
  final String estado;
  final String? motivoRechazo;

  SurveillanceHistoryEntity({
    required this.createdAt,
    required this.name,
    required this.description,
    required this.estado,
    this.motivoRechazo,
    required this.requestId,
    required this.rol,
    required this.amount,
    required this.evidencia,
  });
}

class PaginatedSurveillanceHistoryEntity {
  final List<SurveillanceHistoryEntity> items;
  final bool hasMoreData;
  final int totalRecords;

  PaginatedSurveillanceHistoryEntity({
    required this.items,
    required this.hasMoreData,
    required this.totalRecords,
  });
}
