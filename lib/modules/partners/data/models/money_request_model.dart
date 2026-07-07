import '../../domain/entity/money_request_entity.dart';

class MoneyRequestModel extends MoneyRequestEntity {
  MoneyRequestModel({
    required super.area,
    required super.requestedAmount,
    required super.description,
    required super.evidenceUrlPath,
  });

  // Mapeamos la Entidad de Dominio a este Modelo de Datos
  factory MoneyRequestModel.fromEntity(MoneyRequestEntity entity) {
    return MoneyRequestModel(
      area: entity.area,
      requestedAmount: entity.requestedAmount,
      description: entity.description,
      evidenceUrlPath: entity.evidenceUrlPath,
    );
  }

  Map<String, dynamic> toFormDataMap() {
    return {
      "area": area,
      "requested_amount": requestedAmount,
      "description": description,
    };
  }
}