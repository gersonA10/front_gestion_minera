
import '../../domain/entity/entity.dart';

class MaintenanceHistoryResponseModel extends MaintenanceHistoryResponseEntity {
  MaintenanceHistoryResponseModel({
    required super.currentPage,
    required super.limit,
    required super.totalRecords,
    required super.hasMore,
    required super.items,
  });

  factory MaintenanceHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] ?? {};
    return MaintenanceHistoryResponseModel(
      currentPage: meta['current_page'] ?? 0,
      limit: meta['limit'] ?? 0,
      totalRecords: meta['total_records'] ?? 0,
      hasMore: meta['has_more'] ?? false,
      items: (json['data'] as List<dynamic>)
          .map((e) => MaintenanceHistoryItemModel.fromJson(e))
          .toList(),
    );
  }
}

class MaintenanceHistoryItemModel extends MaintenanceHistoryItemEntity {
  MaintenanceHistoryItemModel({
    required super.maintenanceId,
    required super.machineName,
    required super.machineUniqueCode,
    required super.failureType,
    required super.description,
    required super.estimatedAmount,
    required super.requestedAt,
    required super.globalStatus,
    super.evidenceUrl,
  });

  factory MaintenanceHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceHistoryItemModel(
      maintenanceId: json['maintenance_id'] ?? '',
      machineName: json['machine_name'] ?? '',
      machineUniqueCode: json['machine_unique_code'] ?? '',
      failureType: json['failure_type'] ?? '',
      description: json['description'] ?? '',
      estimatedAmount: (json['estimated_amount'] ?? 0).toDouble(),
      requestedAt: DateTime.tryParse(json['requested_at'] ?? '') ?? DateTime.now(),
      globalStatus: json['global_status'] ?? '',
      evidenceUrl: json['evidence_url'],
    );
  }
}
