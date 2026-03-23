class IncomeResponseEntity {
  final String codigoReferencia;
  final String transactionId;
  final String? evidenciaUrl;

  IncomeResponseEntity({
    required this.codigoReferencia,
    required this.transactionId,
    this.evidenciaUrl,
  });
}