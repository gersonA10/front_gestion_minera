class PendingApplicationsResponseEntity {
  final List<PendingApplicationsEntity> data;
  PendingApplicationsResponseEntity({required this.data});
}

class PendingApplicationsEntity {
  final String requestId;
  final String motivo;
  final String solicitante;
  final int monto;
  final DateTime createdAt;

  PendingApplicationsEntity({
    required this.requestId,
    required this.motivo,
    required this.solicitante,
    required this.monto,
    required this.createdAt,
  });
}
