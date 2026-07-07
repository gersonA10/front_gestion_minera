class MaintenanceHistoryItemEntity {
  final String maintenanceId;
  final String machineName;
  final String machineUniqueCode;
  final String failureType;
  final String description;
  final double estimatedAmount;
  final DateTime requestedAt;
  final String globalStatus;
  final String? evidenceUrl;

  MaintenanceHistoryItemEntity({
    required this.maintenanceId,
    required this.machineName,
    required this.machineUniqueCode,
    required this.failureType,
    required this.description,
    required this.estimatedAmount,
    required this.requestedAt,
    required this.globalStatus,
    this.evidenceUrl,
  });
}

class MaintenanceHistoryResponseEntity {
  final int currentPage;
  final int limit;
  final int totalRecords;
  final bool hasMore;
  final List<MaintenanceHistoryItemEntity> items;

  MaintenanceHistoryResponseEntity({
    required this.currentPage,
    required this.limit,
    required this.totalRecords,
    required this.hasMore,
    required this.items,
  });
}
