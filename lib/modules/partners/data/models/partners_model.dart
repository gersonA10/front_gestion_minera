import 'dart:convert';
import '../../domain/entity/entity.dart';

ContributeHistoryResponseModel loanHistoryResponseFromJson(String str) =>
    ContributeHistoryResponseModel.fromJson(json.decode(str));

class ContributeHistoryResponseModel extends ContributeHistoryResponseEntity {
  ContributeHistoryResponseModel({
    required super.success,
    required super.message,
    required super.data,
  });

  factory ContributeHistoryResponseModel.fromJson(Map<String, dynamic> json) =>
      ContributeHistoryResponseModel(
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
