import '../../domain/entity/request_history_entity.dart';

class RequestHistoryModelAdmin extends RequestHistoryEntity {
  RequestHistoryModelAdmin({
    required super.requestId,
    required super.fechaDecision,
    required super.solicitante,
    required super.rol,
    required super.descripcion,
    required super.monto,
    super.evidenciaUrl,
    required super.estadoGlobalActual,
    super.motivoRechazo,
  });

  factory RequestHistoryModelAdmin.fromJson(Map<String, dynamic> json) {
    return RequestHistoryModelAdmin(
      requestId: json['request_id'] as String? ?? '',
      fechaDecision: DateTime.tryParse(json['fecha_decision'] ?? json['updated_at'] ?? '') ?? DateTime.now(),
      solicitante: json['solicitante'] as String? ?? 'Desconocido',
      rol: json['rol'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      monto: (json['monto'] as num?)?.toDouble() ?? 0.0,
      evidenciaUrl: json['evidencia_url'] as String?,
      estadoGlobalActual: json['estado_global_actual'] ?? json['status'] ?? 'UNKNOWN',
      motivoRechazo: json['motivo_rechazo'] as String?,
    );
  }

  RequestHistoryEntity toEntity() {
    return RequestHistoryEntity(
      requestId: requestId,
      fechaDecision: fechaDecision,
      solicitante: solicitante,
      rol: rol,
      descripcion: descripcion,
      monto: monto,
      evidenciaUrl: evidenciaUrl,
      estadoGlobalActual: estadoGlobalActual,
      motivoRechazo: motivoRechazo,
    );
  }
}