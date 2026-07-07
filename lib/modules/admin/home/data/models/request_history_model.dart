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
    required super.decisionTomada,
  });

  factory RequestHistoryModelAdmin.fromJson(Map<String, dynamic> json) {
    // Coerción segura: el backend puede enviar null o tipos distintos a String.
    String str(dynamic v, [String def = '']) => v == null ? def : v.toString();
    String? strN(dynamic v) => v?.toString();

    final montoRaw = json['monto'];
    final double monto = montoRaw is num
        ? montoRaw.toDouble()
        : double.tryParse(str(montoRaw)) ?? 0.0;

    return RequestHistoryModelAdmin(
      requestId: str(json['request_id']),
      fechaDecision: DateTime.tryParse(
            str(json['fecha_decision'], str(json['updated_at'])),
          ) ??
          DateTime.now(),
      solicitante: str(json['solicitante'], 'Desconocido'),
      rol: str(json['rol']),
      descripcion: str(json['descripcion']),
      monto: monto,
      evidenciaUrl: strN(json['evidencia_url']),
      estadoGlobalActual: json['estado_global_actual'] != null
          ? str(json['estado_global_actual'])
          : str(json['status'], 'UNKNOWN'),
      motivoRechazo: strN(json['motivo_rechazo']),
      decisionTomada: str(json['decision_tomada']),
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
      decisionTomada: decisionTomada,
    );
  }
}