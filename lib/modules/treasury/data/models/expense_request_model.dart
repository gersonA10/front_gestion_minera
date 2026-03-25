import 'package:front_gestion_minera/modules/treasury/domain/entity/entity.dart';

class ExpenseRequestModel extends ExpenseRequestEntity {
  ExpenseRequestModel({
    required super.monto,
    required super.cajaOrigenId,
    required super.concepto,
    required super.evidenceUrlPath,
  });

  factory ExpenseRequestModel.fromEntity(ExpenseRequestEntity entity) {
    return ExpenseRequestModel(
      monto: entity.monto,
      cajaOrigenId: entity.cajaOrigenId,
      concepto: entity.concepto,
      evidenceUrlPath: entity.evidenceUrlPath,
    );
  }

    Map<String, dynamic> toFormDataMap() {
    return {
      "monto": monto,
      "caja_origen_id": cajaOrigenId,
      "concepto": concepto,
    };
  }
}
