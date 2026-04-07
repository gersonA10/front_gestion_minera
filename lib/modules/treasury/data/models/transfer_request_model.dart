import '../../domain/entity/transfer_request_entity.dart';

class TransferRequestModel {
  final double monto;
  final String cajaOrigenId;
  final String cajaDestinoId;
  final String concepto;

  TransferRequestModel({
    required this.monto,
    required this.cajaOrigenId,
    required this.cajaDestinoId,
    required this.concepto,
  });

  factory TransferRequestModel.fromEntity(TransferRequestEntity entity) {
    return TransferRequestModel(
      monto: entity.monto,
      cajaOrigenId: entity.cajaOrigenId,
      cajaDestinoId: entity.cajaDestinoId,
      concepto: entity.concepto,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "monto": monto,
      "caja_origen_id": cajaOrigenId,
      "caja_destino_id": cajaDestinoId,
      "concepto": concepto,
    };
  }
}

class TransferResponseModel extends TransferResponseEntity {
  TransferResponseModel({required super.message});

  factory TransferResponseModel.fromJson(Map<String, dynamic> json) {
    return TransferResponseModel(
      message: json['message'] ?? 'Transferencia exitosa',
    );
  }
}
