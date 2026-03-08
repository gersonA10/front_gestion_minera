class LoanRequestEntity {
  final String loanType;
  final double amountOrQuantity;
  final String description;
  final String comprobanteImg;

  LoanRequestEntity({
    required this.loanType,
    required this.amountOrQuantity,
    required this.description,
    required this.comprobanteImg,
  });
}
