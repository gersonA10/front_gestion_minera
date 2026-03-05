class ContributeHistoryResponseEntity {
  final bool success;
  final String message;
  final List<LoanHistoryDataEntity> data;

  ContributeHistoryResponseEntity({
    required this.success,
    required this.message,
    required this.data,
  });
}

class LoanHistoryDataEntity {
  final String detailId;
  final String motivo;
  final String monto;
  final String estado;
  final DateTime fechaPago;

  LoanHistoryDataEntity({
    required this.detailId,
    required this.motivo,
    required this.monto,
    required this.estado,
    required this.fechaPago,
  });
}
