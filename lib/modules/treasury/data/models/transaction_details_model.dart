

import '../../domain/entity/entity.dart';

class TransactionDetailsResponseModel extends  TransactionDetailsResponseEntity{

    TransactionDetailsResponseModel({
        required super.transactionId,
        required super.referencia,
        required super.monto,
        required super.tipoOperacion,
        required super.concepto,
        required super.fechaHora,
        required super.cajaAfectada,
        required super.responsablePago,
        required super.solicitanteOriginal,
        required super.comprobantesAdjuntos,
    });

    factory TransactionDetailsResponseModel.fromJson(Map<String, dynamic> json) => TransactionDetailsResponseModel(
        transactionId: json["transaction_id"],
        referencia: json["referencia"],
        monto: json["monto"],
        tipoOperacion: json["tipo_operacion"],
        concepto: json["concepto"]??'',
        fechaHora: DateTime.parse(json["fecha_hora"]),
        cajaAfectada: json["caja_afectada"],
        responsablePago: json["responsable_pago"],
        solicitanteOriginal: json["solicitante_original"],
        comprobantesAdjuntos: json["comprobantes_adjuntos"] ?? '',
    );
}
