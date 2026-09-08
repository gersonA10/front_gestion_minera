class NewExtractionResponseEntiy {
  final bool success;
  final String message;
  final String batchCode;
  final bool isIdempotent;

  NewExtractionResponseEntiy({
    required this.success,
    required this.message,
    required this.batchCode,
    this.isIdempotent = false,
  });
}

class NewExtractionRequetsEntity {
  final String extractionDate;
  final String grossWeightGrams;
  final String purityPercent;
  final String observations;

  /// Path de la foto de evidencia. Obligatoria en TODOS los flujos
  /// (el backend también la exige con 400).
  final String evidencia;
  final String idempotencyKey;

  NewExtractionRequetsEntity({
    required this.extractionDate,
    required this.grossWeightGrams,
    required this.purityPercent,
    required this.observations,
    required this.evidencia,
    required this.idempotencyKey,
  });
}
