class CreateCampRequestEntity {
  final String concept;
  final String detail;
  final double requestedAmount;

  const CreateCampRequestEntity({
    required this.concept,
    required this.detail,
    required this.requestedAmount,
  });
}
