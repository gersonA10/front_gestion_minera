import '../../domain/entity/entity.dart';

class PendingRequestModel extends PendingRequestEntity {
  PendingRequestModel({
    required super.requestId,
    required super.fechaRegistro,
    required super.solicitante,
    required super.rol,
    required super.descripcion,
    required super.monto,
    required super.evidenciaUrl,
    required super.estadoVigilancia,
  });

  factory PendingRequestModel.fromJson(Map<String, dynamic> json) {
    return PendingRequestModel(
      requestId: json['request_id'] as String? ?? '',
      fechaRegistro:
          DateTime.tryParse(json['fecha_registro'] as String? ?? '') ??
          DateTime.now(),
      solicitante: json['solicitante'] as String? ?? '',
      rol: json['rol'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      monto: (json['monto'] as num).toDouble(),
      evidenciaUrl: json['evidencia_url'] as String? ?? '',
      estadoVigilancia: json['estado_vigilancia'] as String? ?? '',
    );
  }

  PendingRequestEntity toEntity() {
    return PendingRequestEntity(
      requestId: requestId,
      fechaRegistro: fechaRegistro,
      solicitante: solicitante,
      rol: rol,
      descripcion: descripcion,
      monto: monto,
      evidenciaUrl: evidenciaUrl,
      estadoVigilancia: estadoVigilancia,
    );
  }
}
