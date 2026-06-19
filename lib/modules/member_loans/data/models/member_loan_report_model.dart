import '../../domain/entity/member_loan_report_entity.dart';
import '../json_parse.dart';

class MemberLoanReportModel extends MemberLoanReportEntity {
  MemberLoanReportModel({
    required super.dinero,
    required super.gramos,
    required super.interesPorPeriodo,
    required super.porSocio,
    required super.proximosVencimientos,
  });

  factory MemberLoanReportModel.fromJson(Map<String, dynamic> json) {
    final resumen = (json['resumen'] is Map<String, dynamic>)
        ? json['resumen'] as Map<String, dynamic>
        : <String, dynamic>{};
    final List<dynamic> interes = json['interes_por_periodo'] ?? [];
    final List<dynamic> porSocio = json['por_socio'] ?? [];
    final List<dynamic> vencs = json['proximos_vencimientos_interes'] ?? [];

    return MemberLoanReportModel(
      dinero: _unit(resumen['dinero']),
      gramos: _unit(resumen['gramos']),
      interesPorPeriodo:
          interes.map((e) => _interest(e as Map<String, dynamic>)).toList(),
      porSocio:
          porSocio.map((e) => _socio(e as Map<String, dynamic>)).toList(),
      proximosVencimientos:
          vencs.map((e) => _upcoming(e as Map<String, dynamic>)).toList(),
    );
  }

  static MemberLoanReportUnitEntity _unit(dynamic raw) {
    final j = (raw is Map<String, dynamic>) ? raw : <String, dynamic>{};
    return MemberLoanReportUnitEntity(
      totalPrestado: pNum(j['total_prestado']),
      capitalPendiente: pNum(j['capital_pendiente']),
      capitalPagado: pNum(j['capital_pagado']),
      interesPagado: pNum(j['interes_pagado']),
    );
  }

  static MemberLoanInterestByPeriodEntity _interest(Map<String, dynamic> j) =>
      MemberLoanInterestByPeriodEntity(
        periodo: pStr(j['periodo']),
        dinero: pNum(j['dinero']),
        gramos: pNum(j['gramos']),
      );

  static MemberLoanBySocioEntity _socio(Map<String, dynamic> j) =>
      MemberLoanBySocioEntity(
        socio: pStr(j['socio']),
        memberId: pStrN(j['member_id']),
        vecesPresto: pInt(j['veces_presto']),
        vecesOfrecio: pInt(j['veces_ofrecio']),
        totalDinero: pNum(j['total_dinero']),
        totalGramos: pNum(j['total_gramos']),
        ultimoPrestamo: pDate(j['ultimo_prestamo']),
      );

  static MemberLoanUpcomingInterestEntity _upcoming(Map<String, dynamic> j) =>
      MemberLoanUpcomingInterestEntity(
        periodId: pStr(j['period_id']),
        loanId: pStr(j['loan_id']),
        socio: pStr(j['socio']),
        tipo: pStr(j['tipo']),
        interes: pNum(j['interes']),
        dueDate: pDate(j['due_date']),
      );
}
