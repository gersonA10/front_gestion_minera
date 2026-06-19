/// Reporte agregado de préstamos de socios (GET /api/treasury/members/loans/report).
class MemberLoanReportEntity {
  final MemberLoanReportUnitEntity dinero;
  final MemberLoanReportUnitEntity gramos;
  final List<MemberLoanInterestByPeriodEntity> interesPorPeriodo;
  final List<MemberLoanBySocioEntity> porSocio;
  final List<MemberLoanUpcomingInterestEntity> proximosVencimientos;

  MemberLoanReportEntity({
    required this.dinero,
    required this.gramos,
    required this.interesPorPeriodo,
    required this.porSocio,
    required this.proximosVencimientos,
  });
}

class MemberLoanReportUnitEntity {
  final double totalPrestado;
  final double capitalPendiente;
  final double capitalPagado;
  final double interesPagado;

  MemberLoanReportUnitEntity({
    this.totalPrestado = 0,
    this.capitalPendiente = 0,
    this.capitalPagado = 0,
    this.interesPagado = 0,
  });
}

class MemberLoanInterestByPeriodEntity {
  final String periodo; // "2026-05"
  final double dinero;
  final double gramos;

  MemberLoanInterestByPeriodEntity({
    required this.periodo,
    this.dinero = 0,
    this.gramos = 0,
  });
}

class MemberLoanBySocioEntity {
  final String socio;
  final String? memberId;
  final int vecesPresto;
  final int vecesOfrecio;
  final double totalDinero;
  final double totalGramos;
  final DateTime? ultimoPrestamo;

  MemberLoanBySocioEntity({
    required this.socio,
    this.memberId,
    this.vecesPresto = 0,
    this.vecesOfrecio = 0,
    this.totalDinero = 0,
    this.totalGramos = 0,
    this.ultimoPrestamo,
  });
}

class MemberLoanUpcomingInterestEntity {
  final String periodId;
  final String loanId;
  final String socio;
  final String tipo; // "Dinero" | "Gramos"
  final double interes;
  final DateTime? dueDate;

  MemberLoanUpcomingInterestEntity({
    required this.periodId,
    required this.loanId,
    required this.socio,
    required this.tipo,
    this.interes = 0,
    this.dueDate,
  });

  bool get isGrams => tipo.toLowerCase() == 'gramos';
}
