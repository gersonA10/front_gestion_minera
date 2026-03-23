import 'package:front_gestion_minera/modules/treasury/domain/entity/income_request_entity.dart';

class IncomeRequestModel extends IncomeRequestEntity {
  IncomeRequestModel({
    required super.monto,
    required super.cajaDestinoId,
    required super.concepto,
    required super.evidenceUrlPath,
  });

  factory IncomeRequestModel.fromEntity(IncomeRequestEntity entity) {
    return IncomeRequestModel(
      monto: entity.monto,
      cajaDestinoId: entity.cajaDestinoId,
      concepto: entity.concepto,
      evidenceUrlPath: entity.evidenceUrlPath,
    );
  }

    Map<String, dynamic> toFormDataMap() {
    return {
      "monto": monto,
      "caja_destino_id": cajaDestinoId,
      "concepto": concepto,
    };
  }
}
