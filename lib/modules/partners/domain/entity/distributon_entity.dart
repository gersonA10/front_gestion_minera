class DistributesMetricsEntity {
  final double totalDistribuido;
  final double totalPagado;
  final double totalPendiente;

  DistributesMetricsEntity({
    required this.totalDistribuido,
    required this.totalPagado,
    required this.totalPendiente,
  });
}

class DistributesHistoryEntity {
  final String description;
  final DateTime registeredDate;
  final double amount;
  final String status;

  DistributesHistoryEntity({
    required this.description,
    required this.registeredDate,
    required this.amount,
    required this.status,
  });
}

class PaginatedDistributesHistoryEntity {
  final List<DistributesHistoryEntity> items;
  final bool hasMoreData;

  PaginatedDistributesHistoryEntity({
    required this.items,
    required this.hasMoreData,
  });
}