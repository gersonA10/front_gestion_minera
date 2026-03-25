
import '../../domain/entity/entity.dart';

class ConfirmPaymentResponseModel extends ConfirmPaymentResponseEntity{

    ConfirmPaymentResponseModel({
        required super.success,
        required super.message,
        required super.transactionReference,
    });

    factory ConfirmPaymentResponseModel.fromJson(Map<String, dynamic> json) => ConfirmPaymentResponseModel(
        success: json["success"],
        message: json["message"],
        transactionReference: json["transaction_reference"],
    );
}

class ConfirmPaymentRequestModel extends ConfirmPaymentRequetsEntity {
  ConfirmPaymentRequestModel({
    required super.cajaOrigenId,
    required super.notaPago,
    required super.comprobante,
  });

  factory ConfirmPaymentRequestModel.fromEntity(ConfirmPaymentRequetsEntity entity) {
    return ConfirmPaymentRequestModel(
      cajaOrigenId: entity.cajaOrigenId,
      notaPago: entity.notaPago,
      comprobante: entity.comprobante,
    );
  }

    Map<String, dynamic> toFormDataMap() {
    return {
      "caja_origen_id": cajaOrigenId,
      "nota_pago": notaPago,
      "comprobante": comprobante,
    };
  }
}
