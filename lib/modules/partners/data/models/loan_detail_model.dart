import '../../domain/entity/loan_detail_entity.dart';

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

double? _toDoubleN(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

DateTime? _toDateN(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

class LoanDetailModel extends LoanDetailEntity {
  LoanDetailModel({
    required super.cabecera,
    required super.cronogramaInteres,
    required super.pagos,
  });

  factory LoanDetailModel.fromJson(Map<String, dynamic> json) {
    final cab = (json["cabecera"] is Map<String, dynamic>)
        ? json["cabecera"] as Map<String, dynamic>
        : <String, dynamic>{};
    final List<dynamic> crono = json["cronograma_interes"] ?? [];
    final List<dynamic> pagos = json["pagos"] ?? [];

    return LoanDetailModel(
      cabecera: LoanDetailHeaderEntity(
        loanId: cab["loan_id"]?.toString() ?? '',
        tipo: cab["tipo"]?.toString() ?? '',
        unidad: cab["unidad"]?.toString() ?? '',
        montoTotal: _toDouble(cab["monto_total"]),
        saldoCapitalPendiente: _toDouble(cab["saldo_capital_pendiente"]),
        tieneInteres: cab["tiene_interes"] == true,
        tasaInteresMensual: _toDoubleN(cab["tasa_interes_mensual"]),
        interesDevengado: _toDouble(cab["interes_devengado"]),
        interesPagado: _toDouble(cab["interes_pagado"]),
        interesPendiente: _toDouble(cab["interes_pendiente"]),
        estado: cab["estado"]?.toString() ?? '',
        fechaSolicitud: _toDateN(cab["fecha_solicitud"]),
        fechaAprobacion: _toDateN(cab["fecha_aprobacion"]),
        fechaRechazo: _toDateN(cab["fecha_rechazo"]),
        motivoRechazo: cab["motivo_rechazo"]?.toString(),
        fechaFin: _toDateN(cab["fecha_fin"]),
        motivoCancelacion: cab["motivo_cancelacion"]?.toString(),
      ),
      cronogramaInteres: crono
          .map((e) => _periodFromJson(e as Map<String, dynamic>))
          .toList(),
      pagos:
          pagos.map((e) => _paymentFromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  static LoanInterestPeriodEntity _periodFromJson(Map<String, dynamic> json) =>
      LoanInterestPeriodEntity(
        periodId: json["period_id"]?.toString() ?? '',
        periodNumber: (json["period_number"] is num)
            ? (json["period_number"] as num).toInt()
            : int.tryParse(json["period_number"]?.toString() ?? '') ?? 0,
        periodStart: _toDateN(json["period_start"]),
        dueDate: _toDateN(json["due_date"]),
        principalBase: _toDouble(json["principal_base"]),
        interestAmount: _toDouble(json["interest_amount"]),
        status: json["status"]?.toString() ?? '',
        paidAt: _toDateN(json["paid_at"]),
      );

  static LoanPaymentEntity _paymentFromJson(Map<String, dynamic> json) =>
      LoanPaymentEntity(
        paymentId: json["payment_id"]?.toString() ?? '',
        paymentType: json["payment_type"]?.toString() ?? '',
        amount: _toDouble(json["amount"]),
        paidAt: _toDateN(json["paid_at"]),
        receiptUrl: json["receipt_url"]?.toString(),
        notes: json["notes"]?.toString(),
      );
}
