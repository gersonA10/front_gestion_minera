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
        monto: (json["monto"] as num).toDouble(),
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
///cash

class CashResponseModel extends CashResponseEntity  {
    CashResponseModel({
        required super.data,
    });
    factory CashResponseModel.fromJson(Map<String, dynamic> json) => CashResponseModel(
        data: List<CashDataModel>.from(json["data"].map((x) => CashDataModel.fromJson(x))),
    );
}

class CashDataModel extends  CashDataEntity{
    CashDataModel({
        required super.id,
        required super.nombre,
        required super.saldoDisponible,
    });
    factory CashDataModel.fromJson(Map<String, dynamic> json) => CashDataModel(
        id: json["id"],
        nombre: json["nombre"],
        saldoDisponible: (json["saldo_disponible"] as num).toDouble(),
    );
}
