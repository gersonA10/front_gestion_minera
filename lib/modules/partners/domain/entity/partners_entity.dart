// Métrica de aportes
class ContributionMetricsEntity {
  final double totalAportado;
  final double totalConfirmado;
  final double totalPendiente;

  ContributionMetricsEntity({
    required this.totalAportado,
    required this.totalConfirmado,
    required this.totalPendiente,
  });
}

// Historial
class ContributeHistoryResponseEntity {
  final bool success;
  final String message;
  final List<ContributeHistoryDataEntity> data;

  ContributeHistoryResponseEntity({
    required this.success,
    required this.message,
    required this.data,
  });
}

class ContributeHistoryDataEntity {
  final String detailId;
  final String motivo;
  final double monto;
  final String estado;
  final DateTime fechaPago;

  ContributeHistoryDataEntity({
    required this.detailId,
    required this.motivo,
    required this.monto,
    required this.estado,
    required this.fechaPago,
  });
}