class CloseUpOfAMachineResponseEntity {
  final HeaderMetricsEntity headerMetrics;
  final List<MaintenancesListEntity> maintenancesList;
  final int currentPage;
  final int limit;
  final int totalRecords;
  final bool hasMore;

  CloseUpOfAMachineResponseEntity({
    required this.headerMetrics,
    required this.maintenancesList,
    required this.currentPage,
    required this.limit,
    required this.totalRecords,
    required this.hasMore,
  });
}

class HeaderMetricsEntity {
  final String machineId;
  final String uniqueCode;
  final String name;
  final String type;
  final String typeCode;
  final String status;
  final String description;
  final String photoUrl;
  final DateTime registeredAt;
  final int totalMaintenanceCost;

  HeaderMetricsEntity({
    required this.machineId,
    required this.uniqueCode,
    required this.name,
    required this.type,
    required this.typeCode,
    required this.status,
    required this.description,
    required this.photoUrl,
    required this.registeredAt,
    required this.totalMaintenanceCost,
  });
}

class MaintenancesListEntity {
  final String maintenanceId;
  final String requestId;
  final String failureType;
  final String description;
  final int estimatedAmount;
  final String? evidenciaUrl;
  final DateTime date;
  final String status;

  MaintenancesListEntity({
    required this.maintenanceId,
    required this.requestId,
    required this.failureType,
    required this.description,
    required this.estimatedAmount,
    this.evidenciaUrl,
    required this.date,
    required this.status,
  });
}
