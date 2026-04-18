import 'package:front_gestion_minera/modules/machinery/domain/entity/inventory_machinery_entity.dart';

class InventoryMachineryResponseModel extends InventoryMachineryEntity {
  InventoryMachineryResponseModel({
    required super.currentPage,
    required super.limit,
    required super.totalRecords,
    required super.hasMore,
    required super.machine,
  });
  factory InventoryMachineryResponseModel.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] ?? {};

    return InventoryMachineryResponseModel(
      currentPage: meta['current_page'] ?? 0,
      limit: meta['limit'] ?? 0,
      totalRecords: meta['total_records'] ?? 0,
      hasMore: meta['has_more'] ?? false,
      machine: (json['data'] as List<dynamic>)
          .map((x) => MachineryModel.fromJson(x))
          .toList(),
    );
  }
}

class MachineryModel extends MachineryEntity {
  MachineryModel({
    required super.machineId,
    required super.uniqueCode,
    required super.name,
    required super.type,
    required super.status,
    required super.description,
    required super.photoUrl,
    required super.lastMaintenance,
    required super.registeredAt,
  });
  factory MachineryModel.fromJson(Map<String, dynamic> json) {
    return MachineryModel(
      machineId: json['machine_id'] ?? '',
      uniqueCode: json['unique_code'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      photoUrl: json['photo_url'],
      lastMaintenance: json['last_maintenance'] ?? '',
      registeredAt:
          DateTime.tryParse(json["registered_at"] ?? '') ?? DateTime.now(),
    );
  }
}
