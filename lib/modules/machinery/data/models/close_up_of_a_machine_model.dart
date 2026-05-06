import '../../domain/entity/entity.dart';

class CloseUpOfAMachineResponseModel extends CloseUpOfAMachineResponseEntity {
  CloseUpOfAMachineResponseModel({
    required super.headerMetrics,
    required super.maintenancesList,
    required super.currentPage,
    required super.limit,
    required super.totalRecords,
    required super.hasMore,
  });

  factory CloseUpOfAMachineResponseModel.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return CloseUpOfAMachineResponseModel(
      currentPage: meta['current_page'] ?? 1,
      limit: meta['limit'] ?? 10,
      totalRecords: meta['total_records'] ?? 0,
      hasMore: meta['has_more'] ?? false,
      headerMetrics: HeaderMetricsModel.fromJson(
          json['header_metrics'] as Map<String, dynamic>),
      maintenancesList: (json['maintenances_list'] as List<dynamic>)
          .map((e) => MaintenancesListModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HeaderMetricsModel extends HeaderMetricsEntity {
  HeaderMetricsModel({
    required super.machineId,
    required super.uniqueCode,
    required super.name,
    required super.type,
    required super.typeCode,
    required super.status,
    required super.description,
    required super.photoUrl,
    required super.registeredAt,
    required super.totalMaintenanceCost,
  });

  factory HeaderMetricsModel.fromJson(Map<String, dynamic> json) =>
      HeaderMetricsModel(
        machineId: json['machine_id'] ?? '',
        uniqueCode: json['unique_code'] ?? '',
        name: json['name'] ?? '',
        type: json['type'] ?? '',
        typeCode: json['type_code'] ?? '',
        status: json['status'] ?? '',
        description: json['description'] ?? '',
        photoUrl: json['photo_url'] ?? '',
        registeredAt: DateTime.parse(json['registered_at']),
        totalMaintenanceCost: (json['total_maintenance_cost'] ?? 0).toInt(),
      );
}

class MaintenancesListModel extends MaintenancesListEntity {
  MaintenancesListModel({
    required super.maintenanceId,
    required super.requestId,
    required super.failureType,
    required super.description,
    required super.estimatedAmount,
    super.evidenciaUrl,
    required super.date,
    required super.status,
  });

  factory MaintenancesListModel.fromJson(Map<String, dynamic> json) =>
      MaintenancesListModel(
        maintenanceId: json['maintenance_id'] ?? '',
        requestId: json['request_id'] ?? '',
        failureType: json['failure_type'] ?? '',
        description: json['description'] ?? '',
        estimatedAmount: (json['estimated_amount'] ?? 0).toInt(),
        evidenciaUrl: json['evidencia_url'],
        date: DateTime.parse(json['date']),
        status: json['status'] ?? '',
      );
}
