
import '../../domain/entity/entity.dart';

class SurveillanceHistoryModel extends SurveillanceHistoryEntity {
  SurveillanceHistoryModel({
    required super.createdAt,
    required super.name,
    required super.description,
    required super.estado,
    super.motivoRechazo,
  });

  factory SurveillanceHistoryModel.fromJson(Map<String, dynamic> json) {
    return SurveillanceHistoryModel(
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      name: json['name'] ?? 'Sin nombre',
      description: json['description'] ?? 'Sin descripción',
      estado: json['estado'] ?? 'Pendiente',
      motivoRechazo: json['motivo_rechazo'],
    );
  }

  SurveillanceHistoryEntity toEntity() {
    return SurveillanceHistoryEntity(
      createdAt: createdAt,
      name: name,
      description: description,
      estado: estado,
      motivoRechazo: motivoRechazo,
    );
  }
}