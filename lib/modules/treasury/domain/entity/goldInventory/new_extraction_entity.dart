class NewExtractionResponseEntiy {
    final bool success;
    final String message;
    final String batchCode;

    NewExtractionResponseEntiy({
        required this.success,
        required this.message,
        required this.batchCode,
    });
}
class NewExtractionRequetsEntity {
 final String extractionDate;
  final String grossWeightGrams;
  final String purityPercent;
  final String observations;
  final String evidencia;

    NewExtractionRequetsEntity({
       required this.extractionDate,
    required this.grossWeightGrams,
    required this.purityPercent,
    required this.observations,
    required this.evidencia,
    });
}