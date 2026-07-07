import '../../domain/entity/income_response_entity.dart';

class IncomeResponseModel extends IncomeResponseEntity {
  IncomeResponseModel({
    required super.codigoReferencia,
    required super.transactionId,
    super.evidenciaUrl,
  });

  factory IncomeResponseModel.fromJson(Map<String, dynamic> json) {
    return IncomeResponseModel(
      codigoReferencia: json['codigo_referencia'],
      transactionId: json['transaction_id'],
      evidenciaUrl: json['evidencia_url'],
    );
  }
}