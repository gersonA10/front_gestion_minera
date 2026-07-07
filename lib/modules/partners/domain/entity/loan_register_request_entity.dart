class LoanRequestEntity {
  final String loanType;
  final double amountOrQuantity;
  final String description;
  final String comprobanteImg;

  /// El socio decide si su préstamo a la empresa pacta interés.
  final bool hasInterest;

  /// Tasa de interés mensual (%) — solo aplica si [hasInterest] es true.
  final double? interestRate;

  LoanRequestEntity({
    required this.loanType,
    required this.amountOrQuantity,
    required this.description,
    required this.comprobanteImg,
    this.hasInterest = false,
    this.interestRate,
  });
}
