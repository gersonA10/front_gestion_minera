import '../../domain/entity/entity.dart';

class PendingApplicationsResponseModel
    extends PendingApplicationsResponseEntity {
  PendingApplicationsResponseModel({required super.data});

  factory PendingApplicationsResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => PendingApplicationsResponseModel(
    data: List<PendingApplicationsModel>.from(
      json["data"].map((x) => PendingApplicationsModel.fromJson(x)),
    ),
  );
}

class PendingApplicationsModel extends PendingApplicationsEntity {
  PendingApplicationsModel({
    required super.requestId,
    required super.motivo,
    required super.solicitante,
    required super.monto,
    required super.createdAt,
  });

  factory PendingApplicationsModel.fromJson(Map<String, dynamic> json) =>
      PendingApplicationsModel(
        requestId: json["request_id"],
        motivo: json["motivo"],
        solicitante: json["solicitante"],
        monto: json["monto"],
        createdAt: DateTime.parse(json["created_at"]),
      );
}
