import 'package:front_gestion_minera/modules/treasury/domain/entity/loans/payment_process_entity.dart';

class PayTheFeeResponseModel extends PayTheFeeResponseEntity {
  PayTheFeeResponseModel({
    required super.montoPagado,
    required super.referencia,
    required super.fechaHora,
    required super.cajaAfectada,
    required super.transactionId,
  });

  factory PayTheFeeResponseModel.fromJson(Map<String, dynamic> json) =>
      PayTheFeeResponseModel(
        montoPagado: (json["monto_pagado"] as num).toDouble(),
        referencia: json["referencia"],
        fechaHora: json["fecha_hora"],
        cajaAfectada: json["caja_afectada"],
        transactionId: json["transaction_id"],
      );
}

class PayTheFeeRequestModel extends PayTheFeeRequetsEntity {
  PayTheFeeRequestModel({
    required super.cajaOrigenId,
    required super.metodoPago,
    required super.referencia,
    required super.fechaPago,
    required super.comprobante,
  });

  factory PayTheFeeRequestModel.fromEntity(PayTheFeeRequetsEntity entity) {
    return PayTheFeeRequestModel(
      cajaOrigenId: entity.cajaOrigenId,
      metodoPago: entity.metodoPago,
      referencia: entity.referencia,
      fechaPago: entity.fechaPago,
      comprobante: entity.comprobante,
    );
  }

  Map<String, dynamic> toFormDataMap() => {
    "caja_origen_id": cajaOrigenId,
    "metodo_pago": metodoPago,
    "referencia": referencia,
    "fecha_pago": fechaPago,
    "comprobante": comprobante,
  };
}
