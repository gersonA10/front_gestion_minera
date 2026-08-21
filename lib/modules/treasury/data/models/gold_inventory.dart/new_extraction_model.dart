import '../../../domain/entity/entity.dart';

class NewExtractionResponseModel extends NewExtractionResponseEntiy {
  NewExtractionResponseModel({
    required super.success,
    required super.message,
    required super.batchCode,
    super.isIdempotent,
  });

  factory NewExtractionResponseModel.fromJson(Map<String, dynamic> json) =>
      NewExtractionResponseModel(
        success: json["success"],
        message: json["message"],
        batchCode: json["batch_code"],
        isIdempotent: json["idempotent_replay"] == true,
      );
}

class NewExtractionRequestModel extends NewExtractionRequetsEntity {
  NewExtractionRequestModel({
    required super.extractionDate,
    required super.grossWeightGrams,
    required super.purityPercent,
    required super.observations,
    required super.evidencia,
    required super.idempotencyKey,
  });

  factory NewExtractionRequestModel.fromEntity(
    NewExtractionRequetsEntity entity,
  ) {
    return NewExtractionRequestModel(
      evidencia: entity.evidencia,
      grossWeightGrams: entity.grossWeightGrams,
      purityPercent: entity.purityPercent,
      observations: entity.observations,
      extractionDate: entity.extractionDate,
      idempotencyKey: entity.idempotencyKey,
    );
  }

  Map<String, dynamic> toFormDataMap() {
    return {
      "extraction_date": extractionDate,
      "gross_weight_grams": grossWeightGrams,
      "purity_percent": purityPercent,
      "observations": observations,
      "evidencia": evidencia,
    };
  }
}
