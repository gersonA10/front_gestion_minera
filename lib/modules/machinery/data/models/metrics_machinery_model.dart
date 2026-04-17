import 'package:front_gestion_minera/modules/machinery/domain/entity/entity.dart';

class MetricsMachineryModel extends MetricsMachineryEntity {
  MetricsMachineryModel({
    required super.total,
    required super.operationalMachines,
    required super.underMaintenance,
    required super.inactiveMachines,
  });
  factory MetricsMachineryModel.fromJson(Map<String, dynamic> json) {
    return MetricsMachineryModel(
      total: (json['total'] ?? 0).toInt(),
      operationalMachines: (json['operational_machines'] ?? 0).toInt(),
      underMaintenance: (json['under_maintenance'] ?? 0).toInt(),
      inactiveMachines: (json['incative_machines'] ?? 0).toInt(),
    );
  }
}
