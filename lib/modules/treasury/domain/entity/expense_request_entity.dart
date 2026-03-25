class ExpenseRequestEntity {
  final double monto;
  final String cajaOrigenId;
  final String concepto;
  final String evidenceUrlPath;

  ExpenseRequestEntity({
    required this.monto,
    required this.cajaOrigenId,
    required this.concepto,
    required this.evidenceUrlPath,
  });
}