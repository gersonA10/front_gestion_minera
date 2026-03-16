import '../../domain/entity/entity.dart';

class SurveillanceHistoryModel extends SurveillanceHistoryEntity {
  SurveillanceHistoryModel({
    required super.createdAt,
    required super.name,
    required super.description,
    required super.estado,
    super.motivoRechazo,
    required super.requestId,
    required super.rol,
    required super.amount,
    required super.evidencia,
  });

  factory SurveillanceHistoryModel.fromJson(Map<String, dynamic> json) {
    return SurveillanceHistoryModel(
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      name: json['name'] ?? 'Sin nombre',
      description: json['description'] ?? 'Sin descripción',
      estado: json['estado'] ?? 'Pendiente',
      motivoRechazo: json['motivo_rechazo'],
      requestId: json['request_id'],
      rol: json['rol'],
      amount: json['amount'],
      evidencia: json['evidencia'],
    );
  }

  SurveillanceHistoryEntity toEntity() {
    return SurveillanceHistoryEntity(
      createdAt: createdAt,
      name: name,
      description: description,
      estado: estado,
      motivoRechazo: motivoRechazo,
      requestId: requestId,
      rol: rol,
      amount: amount,
      evidencia: evidencia,
    );
  }
}
