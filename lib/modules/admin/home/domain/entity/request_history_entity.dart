class RequestHistoryEntity {
  final String requestId;
  final DateTime fechaDecision;
  final String solicitante;
  final String rol;
  final String descripcion;
  final double monto;
  final String? evidenciaUrl;
  final String estadoGlobalActual;
  final String decisionTomada;
  final String? motivoRechazo;

  RequestHistoryEntity({
    required this.requestId,
    required this.fechaDecision,
    required this.solicitante,
    required this.rol,
    required this.descripcion,
    required this.monto,
    required this.decisionTomada,
    this.evidenciaUrl,
    required this.estadoGlobalActual,
    this.motivoRechazo,
  });

  bool get isApproved => decisionTomada.toUpperCase() == 'APPROVED' || decisionTomada.toUpperCase() == 'APROBADO';
  bool get isRejected => decisionTomada.toUpperCase() == 'REJECTED' || decisionTomada.toUpperCase() == 'RECHAZADO';

  String get shortCode {
    final clean = requestId.replaceAll('-', '');
    if (clean.isEmpty) return '#SOL-----';
    final take = clean.length >= 4 ? clean.substring(0, 4) : clean;
    return '#SOL-${take.toUpperCase()}';
  }
}

class PaginatedRequestHistoryEntity {
  final List<RequestHistoryEntity> items;
  final bool hasMoreData;
  final int totalRecords;

  PaginatedRequestHistoryEntity({
    required this.items,
    required this.hasMoreData,
    required this.totalRecords,
  });
}