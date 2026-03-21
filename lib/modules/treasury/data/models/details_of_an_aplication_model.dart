import '../../domain/entity/entity.dart';

class DetailsofanapplicationResponseModel
    extends DetailsofanapplicationResponseEntity {
  DetailsofanapplicationResponseModel({
    required super.success,
    required super.message,
    required super.data,
  });

  factory DetailsofanapplicationResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => DetailsofanapplicationResponseModel(
    success: json["success"],
    message: json["message"],
    data: DetailsofanapplicationDataModel.fromJson(json["data"]),
  );
}

class DetailsofanapplicationDataModel extends DetailsofanapplicationDataEntity {
  DetailsofanapplicationDataModel({
    required super.requestId,
    required super.monto,
    required super.descripcion,
    required super.solicitante,
    required super.createdAt,
    required super.flujoAprobacion,
    required super.evidenciaUrl,
  });

  factory DetailsofanapplicationDataModel.fromJson(Map<String, dynamic> json) =>
      DetailsofanapplicationDataModel(
        requestId: json["request_id"],
        monto: json["monto"],
        descripcion: json["descripcion"],
        solicitante: json["solicitante"],
        createdAt: DateTime.parse(json["created_at"]),
        flujoAprobacion: List<FlujoAprobacionModel>.from(
          json["flujo_aprobacion"].map((x) => FlujoAprobacionModel.fromJson(x)),
        ),
        evidenciaUrl: json["evidencia_url"],
      );
}

class FlujoAprobacionModel extends FlujoAprobacionEntity {
  FlujoAprobacionModel({
    required super.etapa,
    required super.aprobador,
    required super.fecha,
  });

  factory FlujoAprobacionModel.fromJson(Map<String, dynamic> json) =>
      FlujoAprobacionModel(
        etapa: json["etapa"],
        aprobador: json["aprobador"],
        fecha: DateTime.parse(json["fecha"]),
      );
}
