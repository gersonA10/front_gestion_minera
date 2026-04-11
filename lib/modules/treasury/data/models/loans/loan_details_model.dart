

import '../../../domain/entity/entity.dart';

class LoanDetailsResponseModel extends LoanDetailsResponseEntity{

    LoanDetailsResponseModel({
        required super.success,
        required super.data,
    });

    factory LoanDetailsResponseModel.fromJson(Map<String, dynamic> json) => LoanDetailsResponseModel(
        success: json["success"],
        data: LoanDetailsDataModel.fromJson(json["data"]),
    );
}

class LoanDetailsDataModel  extends LoanDetailsDataEntity{

    LoanDetailsDataModel({
        required super.cabecera,
        required super.cronograma,
    });

    factory LoanDetailsDataModel.fromJson(Map<String, dynamic> json) => LoanDetailsDataModel(
        cabecera: CabeceraModel.fromJson(json["cabecera"]),
        cronograma: List<LoanDetailCronogramaModel>.from(json["cronograma"].map((x) => LoanDetailCronogramaModel.fromJson(x))),
    );
}

class CabeceraModel extends CabeceraEntity {

    CabeceraModel({
        required super.loanCode,
        required super.estadoEtiqueta,
        required super.montoPrincipal,
        required super.moneda,
        required super.interesTotal,
        required super.totalAPagar,
        required super.saldoPendiente,
        required super.progresoPagoPct,
    });

    factory CabeceraModel.fromJson(Map<String, dynamic> json) => CabeceraModel(
        loanCode: json["loan_code"],
        estadoEtiqueta: json["estado_etiqueta"],
        montoPrincipal: json["monto_principal"],
        moneda: json["moneda"],
        interesTotal: json["interes_total"] is int ? json["interes_total"] : json["interes_total"].toInt(),
        totalAPagar: json["total_a_pagar"] is int ? json["total_a_pagar"] : json["total_a_pagar"].toInt(),
        saldoPendiente: json["saldo_pendiente"] is int ? json["saldo_pendiente"] : json["saldo_pendiente"].toInt(),
        progresoPagoPct: json["progreso_pago_pct"],
    );
}

class LoanDetailCronogramaModel extends LoanDetailCronogramaEntity {
   
    LoanDetailCronogramaModel({
        required super.quotaId,
        required super.mesEtiqueta,
        required super.diaEtiqueta,
        required super.textoCuota,
        required super.estadoCuota,
        required super.montoTotalCuota,
        required super.permitePago,
    });

    factory LoanDetailCronogramaModel.fromJson(Map<String, dynamic> json) => LoanDetailCronogramaModel(
        quotaId: json["quota_id"],
        mesEtiqueta: json["mes_etiqueta"],
        diaEtiqueta: json["dia_etiqueta"],
        textoCuota: json["texto_cuota"],
        estadoCuota: json["estado_cuota"],
        montoTotalCuota: json["monto_total_cuota"] is int ? json["monto_total_cuota"] : json["monto_total_cuota"].toInt(),
        permitePago: json["permite_pago"],
    );
}
