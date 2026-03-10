class SurveillanceHistoryEntity {
  final DateTime createdAt;
  final String name;
  final String description;
  final String estado;
  final String? motivoRechazo;

  SurveillanceHistoryEntity({
    required this.createdAt,
    required this.name,
    required this.description,
    required this.estado,
    this.motivoRechazo,
  });
}

class PaginatedSurveillanceHistoryEntity {
  final List<SurveillanceHistoryEntity> items;
  final bool hasMoreData;

  PaginatedSurveillanceHistoryEntity({
    required this.items,
    required this.hasMoreData,
  });
}