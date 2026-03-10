import '../../domain/entity/entity.dart';

class MonitoringTrayDataModel extends MonitoringTrayDataEntity {
  MonitoringTrayDataModel({
    required super.createdAt,
    required super.name,
    required super.rol,
    required super.description,
    required super.status,
    required super.amount,
    required super.evidencia,
  });

  factory MonitoringTrayDataModel.fromJson(Map<String, dynamic> json) =>
      MonitoringTrayDataModel(
        createdAt:
            DateTime.tryParse(json["created_at"] ?? '') ?? DateTime.now(),
        name: json["name"],
        rol: json["rol"],
        description: json["description"],
        status: json["status"],
        amount: json["amount"],
        evidencia: json["evidencia"],
      );
  MonitoringTrayDataEntity toEntity() {
    return MonitoringTrayDataEntity(
      description: description,
      amount: amount,
      status: status,
      createdAt: createdAt,
      name: name,
      rol: rol,
      evidencia: evidencia,
    );
  }
}
