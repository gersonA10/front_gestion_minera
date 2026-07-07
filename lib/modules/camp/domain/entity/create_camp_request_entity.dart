class CreateCampRequestEntity {
  final String concept;
  final String detail;
  final double requestedAmount;

  /// Fecha estimada de compra que selecciona el jefe de campamento.
  final DateTime estimatedPurchaseDate;

  const CreateCampRequestEntity({
    required this.concept,
    required this.detail,
    required this.requestedAmount,
    required this.estimatedPurchaseDate,
  });
}
