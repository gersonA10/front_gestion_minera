import '../../domain/entity/member_loan_detail_entity.dart';
import '../json_parse.dart';

class MemberLoanDetailModel extends MemberLoanDetailEntity {
  MemberLoanDetailModel({
    required super.cabecera,
    required super.cronogramaInteres,
    required super.pagos,
  });

  factory MemberLoanDetailModel.fromJson(Map<String, dynamic> json) {
    final cab = (json['cabecera'] is Map<String, dynamic>)
        ? json['cabecera'] as Map<String, dynamic>
        : <String, dynamic>{};
    final List<dynamic> crono = json['cronograma_interes'] ?? [];
    final List<dynamic> pagos = json['pagos'] ?? [];

    return MemberLoanDetailModel(
      cabecera: MemberLoanDetailHeaderEntity(
        loanId: pStr(cab['loan_id']),
        socio: pStr(cab['socio']),
        identificacion: pStrN(cab['identificacion']),
        telefono: pStrN(cab['telefono']),
        tipo: pStr(cab['tipo']),
        unidad: pStr(cab['unidad']),
        montoTotal: pNum(cab['monto_total']),
        capitalPendiente: pNum(cab['capital_pendiente']),
        capitalPagado: pNum(cab['capital_pagado']),
        tieneInteres: cab['tiene_interes'] == true,
        tasaInteresMensual: pNumN(cab['tasa_interes_mensual']),
        interesDevengado: pNum(cab['interes_devengado']),
        interesPagado: pNum(cab['interes_pagado']),
        interesPendiente: pNum(cab['interes_pendiente']),
        estado: pStr(cab['estado']),
        vecesPrestoSocio: pInt(cab['veces_presto_socio']),
        fechaSolicitud: pDate(cab['fecha_solicitud']),
        fechaAprobacion: pDate(cab['fecha_aprobacion']),
        fechaRechazo: pDate(cab['fecha_rechazo']),
        motivoRechazo: pStrN(cab['motivo_rechazo']),
        fechaFin: pDate(cab['fecha_fin']),
        fechaCancelacion: pDate(cab['fecha_cancelacion']),
        motivoCancelacion: pStrN(cab['motivo_cancelacion']),
        comprobanteUrl: pStrN(cab['comprobante_url']),
        loteGenerado: pStrN(cab['lote_generado']),
      ),
      cronogramaInteres: crono
          .map((e) => _period(e as Map<String, dynamic>))
          .toList(),
      pagos: pagos.map((e) => _payment(e as Map<String, dynamic>)).toList(),
    );
  }

  static MemberLoanInterestPeriodEntity _period(Map<String, dynamic> json) =>
      MemberLoanInterestPeriodEntity(
        periodId: pStr(json['period_id']),
        periodNumber: pInt(json['period_number']),
        periodStart: pDate(json['period_start']),
        dueDate: pDate(json['due_date']),
        principalBase: pNum(json['principal_base']),
        interestAmount: pNum(json['interest_amount']),
        status: pStr(json['status']),
        paidAt: pDate(json['paid_at']),
      );

  static MemberLoanPaymentEntity _payment(Map<String, dynamic> json) =>
      MemberLoanPaymentEntity(
        paymentId: pStr(json['payment_id']),
        paymentType: pStr(json['payment_type']),
        periodId: pStrN(json['period_id']),
        amount: pNum(json['amount']),
        paidAt: pDate(json['paid_at']),
        receiptUrl: pStrN(json['receipt_url']),
        notes: pStrN(json['notes']),
        cashRegisterId: pStrN(json['cash_register_id']),
        transactionId: pStrN(json['transaction_id']),
      );
}
