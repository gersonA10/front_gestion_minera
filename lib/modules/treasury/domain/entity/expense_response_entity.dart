class ExpenseResponseEntity {
  final String codigoReferencia;
  final String transactionId;
  final String? evidenciaUrl;

  ExpenseResponseEntity({
    required this.codigoReferencia,
    required this.transactionId,
    this.evidenciaUrl,
  });
}