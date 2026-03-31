class RequestHistoryEntity {
  final String requestId;
  final DateTime fechaDecision;
  final String solicitante;
  final String rol;
  final String descripcion;
  final double monto;
  final String? evidenciaUrl;
  final String estadoGlobalActual;
  final String? motivoRechazo;

  RequestHistoryEntity({
    required this.requestId,
    required this.fechaDecision,
    required this.solicitante,
    required this.rol,
    required this.descripcion,
    required this.monto,
    this.evidenciaUrl,
    required this.estadoGlobalActual,
    this.motivoRechazo,
  });

  bool get isApproved => estadoGlobalActual.toUpperCase() == 'APPROVED' || estadoGlobalActual.toUpperCase() == 'APROBADO';
  bool get isRejected => estadoGlobalActual.toUpperCase() == 'REJECTED' || estadoGlobalActual.toUpperCase() == 'RECHAZADO';

  String get shortCode {
    final clean = requestId.replaceAll('-', '');
    return '#SOL-${clean.substring(0, 4).toUpperCase()}';
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