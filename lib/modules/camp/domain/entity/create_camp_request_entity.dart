class CreateCampRequestEntity {
  final String concept;
  final String detail;
  final double requestedAmount;
  final String evidencePath;

  const CreateCampRequestEntity({
    required this.concept,
    required this.detail,
    required this.requestedAmount,
    required this.evidencePath,
  });
}
