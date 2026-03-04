import 'dart:convert';
import 'package:front_gestion_minera/modules/partners/domain/entity/partners_entity.dart';

LoanHistoryResponseModel loanHistoryResponseFromJson(String str) =>
    LoanHistoryResponseModel.fromJson(json.decode(str));

class LoanHistoryResponseModel extends LoanHistoryResponseEntity {
  LoanHistoryResponseModel({
    required super.success,
    required super.message,
    required super.data,
  });

  factory LoanHistoryResponseModel.fromJson(Map<String, dynamic> json) =>
      LoanHistoryResponseModel(
        success: json["success"],
        message: json["message"],
        data: List<LoanHistoryDataModel>.from(
          json["data"].map((x) => LoanHistoryDataModel.fromJson(x)),
        ),
      );
}

class LoanHistoryDataModel extends LoanHistoryDataEntity {
  LoanHistoryDataModel({
    required super.detailId,
    required super.motivo,
    required super.monto,
    required super.estado,
    required super.fechaPago,
  });

  factory LoanHistoryDataModel.fromJson(Map<String, dynamic> json) =>
      LoanHistoryDataModel(
        detailId: json["detail_id"],
        motivo: json["motivo"],
        monto: json["monto"],
        estado: json["estado"],
        fechaPago: DateTime.parse(json["fecha_pago"]),
      );
}
