


import '../../../domain/entity/entity.dart';

class InternalLoansResponseModel extends  InternalLoansEntity{

    InternalLoansResponseModel({
        required super.loanId,
        required super.lenderName,
        required super.loanCode,
        required super.estadoEtiqueta,
        required super.montoPrestado,
        required super.totalAPagar,
        required super.pendiente,
        required super.progresoPagoPct,
        required super.alertaVencimiento,
    });

    factory InternalLoansResponseModel.fromJson(Map<String, dynamic> json) => InternalLoansResponseModel(
        loanId: json["loan_id"],
        lenderName: json["lender_name"],
        loanCode: json["loan_code"],
        estadoEtiqueta: json["estado_etiqueta"],
        montoPrestado: json["monto_prestado"] is int ? json["monto_prestado"].toDouble() : json["monto_prestado"],
        totalAPagar: json["total_a_pagar"] is int ? json["total_a_pagar"].toDouble() : json["total_a_pagar"],
        pendiente: json["pendiente"] is int ? json["pendiente"].toDouble() : json["pendiente"],
        progresoPagoPct: json["progreso_pago_pct"],
        alertaVencimiento: AlertaVencimientoModel.fromJson(json["alerta_vencimiento"]),
    );
    InternalLoansEntity toEntity() {
    return InternalLoansEntity(
      lenderName: lenderName,
      loanCode: loanCode,
      estadoEtiqueta: estadoEtiqueta,
      loanId: loanId,
      montoPrestado: montoPrestado,
      totalAPagar: totalAPagar,
      pendiente: pendiente,
      progresoPagoPct: progresoPagoPct,
      alertaVencimiento: alertaVencimiento
    );
  }
}

class AlertaVencimientoModel extends AlertaVencimientoEntity {

    AlertaVencimientoModel({
        required super.estaEnMora,
        required super.textoFecha,
    });

    factory AlertaVencimientoModel.fromJson(Map<String, dynamic> json) => AlertaVencimientoModel(
        estaEnMora: json["esta_en_mora"],
        textoFecha: json["texto_fecha"],
    );
}
