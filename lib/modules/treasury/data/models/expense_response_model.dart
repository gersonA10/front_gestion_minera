import 'package:front_gestion_minera/modules/treasury/domain/entity/entity.dart';


class ExpenseResponseModel extends ExpenseResponseEntity {
  ExpenseResponseModel({
    required super.codigoReferencia,
    required super.transactionId,
    super.evidenciaUrl,
  });

  factory ExpenseResponseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseResponseModel(
      codigoReferencia: json['codigo_referencia'],
      transactionId: json['transaction_id'],
      evidenciaUrl: json['evidencia_url'],
    );
  }
}