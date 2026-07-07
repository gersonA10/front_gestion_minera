import '../../domain/entity/member_loan_list_entity.dart';
import '../json_parse.dart';

class MemberLoanListItemModel extends MemberLoanListItemEntity {
  MemberLoanListItemModel({
    required super.loanId,
    required super.socio,
    required super.tipo,
    required super.loanType,
    required super.montoOGramos,
    super.capitalPendiente,
    super.hasInterest,
    super.tasaInteresMensual,
    required super.estado,
    required super.status,
    super.createdAt,
    super.approvedAt,
    super.rejectedAt,
    super.rejectReason,
    super.endDate,
    super.cancelledAt,
    super.cancellationReason,
    super.interesPagado,
  });

  factory MemberLoanListItemModel.fromJson(Map<String, dynamic> json) =>
      MemberLoanListItemModel(
        loanId: pStr(json['loan_id']),
        socio: pStr(json['socio']),
        tipo: pStr(json['tipo']),
        loanType: pStr(json['loan_type']),
        montoOGramos: pNum(json['monto_o_gramos']),
        capitalPendiente: pNumN(json['capital_pendiente']),
        hasInterest: json['has_interest'] == true,
        tasaInteresMensual: pNumN(json['tasa_interes_mensual']),
        estado: pStr(json['estado']),
        status: pStr(json['status']),
        createdAt: pDate(json['created_at']),
        approvedAt: pDate(json['approved_at']),
        rejectedAt: pDate(json['rejected_at']),
        rejectReason: pStrN(json['reject_reason']),
        endDate: pDate(json['end_date']),
        cancelledAt: pDate(json['cancelled_at']),
        cancellationReason: pStrN(json['cancellation_reason']),
        interesPagado: pNum(json['interes_pagado']),
      );

  static MemberLoanPageEntity pageFromResponse(Map<String, dynamic> json) {
    final List<dynamic> data = json['data'] ?? [];
    final Map<String, dynamic> meta = json['meta'] ?? {};
    return MemberLoanPageEntity(
      items: data
          .map((e) =>
              MemberLoanListItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: meta['has_more'] == true || meta['has_more_data'] == true,
      totalRecords: pInt(meta['total_records']),
    );
  }
}
