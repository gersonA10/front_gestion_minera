import '../../domain/entity/entity.dart';

class RequestDetailModel {
  final String requestId;
  final String fechaRegistro;
  final String solicitante;
  final String rol;
  final String descripcion;
  final double monto;
  final String evidenciaUrl;
  final Map<String, dynamic> estados;
  final Map<String, dynamic> fechasAuditoria;

  RequestDetailModel({
    required this.requestId,
    required this.fechaRegistro,
    required this.solicitante,
    required this.rol,
    required this.descripcion,
    required this.monto,
    required this.evidenciaUrl,
    required this.estados,
    required this.fechasAuditoria,
  });

  factory RequestDetailModel.fromJson(Map<String, dynamic> json) {
    return RequestDetailModel(
      requestId: json['request_id'] ?? '',
      fechaRegistro: json['fecha_registro'] ?? '',
      solicitante: json['solicitante'] ?? '',
      rol: json['rol'] ?? '',
      descripcion: json['descripcion'] ?? '',
      monto: (json['monto'] ?? 0).toDouble(),
      evidenciaUrl: json['evidencia_url'] ?? '',
      estados: json['estados'] ?? {},
      fechasAuditoria: json['fechas_auditoria'] ?? {},
    );
  }

  RequestDetailEntity toEntity() {
    return RequestDetailEntity(
      requestId: requestId,
      fechaRegistro: DateTime.tryParse(fechaRegistro) ?? DateTime.now(),
      solicitante: solicitante,
      rol: rol,
      descripcion: descripcion,
      monto: monto,
      evidenciaUrl: evidenciaUrl,
      estadoVigilancia: estados['vigilancia'] ?? 'Desconocido',
      estadoAdministracion: estados['administracion'] ?? 'Desconocido',
      vigilanciaAprobadoEl: fechasAuditoria['vigilancia_aprobado_el'] != null 
          ? DateTime.tryParse(fechasAuditoria['vigilancia_aprobado_el']) 
          : null,
    );
  }
}