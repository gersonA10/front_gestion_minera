class IncomeRequestEntity {
  final double monto;
  final String cajaDestinoId;
  final String concepto;
  final String evidenceUrlPath;

  IncomeRequestEntity({
    required this.monto,
    required this.cajaDestinoId,
    required this.concepto,
    required this.evidenceUrlPath,
  });
}