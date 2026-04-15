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
      total: json['total'].toInt() ?? 0,
      operationalMachines: json['operational_machines'].toInt() ?? 0,
      underMaintenance: json['under_maintenance'].toInt() ?? 0,
      inactiveMachines: json['incative_machines'].toInt() ?? 0,
    );
  }
}
