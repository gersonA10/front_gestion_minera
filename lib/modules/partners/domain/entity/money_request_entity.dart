class MoneyRequestEntity {
  final String area;
  final double requestedAmount;
  final String description;
  final String evidenceUrlPath;

  MoneyRequestEntity({
    required this.area,
    required this.requestedAmount,
    required this.description,
    required this.evidenceUrlPath,
  });
}