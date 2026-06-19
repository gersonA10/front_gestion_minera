/// Detalle del préstamo del socio (GET /api/loans/:loan_id).
class LoanDetailEntity {
  final LoanDetailHeaderEntity cabecera;
  final List<LoanInterestPeriodEntity> cronogramaInteres;
  final List<LoanPaymentEntity> pagos;

  LoanDetailEntity({
    required this.cabecera,
    required this.cronogramaInteres,
    required this.pagos,
  });
}

class LoanDetailHeaderEntity {
  final String loanId;
  final String tipo; // "Dinero" | "Gramos"
  final String unidad; // "Bs" | "g"
  final double montoTotal;
  final double saldoCapitalPendiente;
  final bool tieneInteres;
  final double? tasaInteresMensual;
  final double interesDevengado;
  final double interesPagado;
  final double interesPendiente;
  final String estado; // PENDING | APPROVED | PAID | REJECTED | CANCELLED
  final DateTime? fechaSolicitud;
  final DateTime? fechaAprobacion;
  final DateTime? fechaRechazo;
  final String? motivoRechazo;
  final DateTime? fechaFin;
  final String? motivoCancelacion;

  LoanDetailHeaderEntity({
    required this.loanId,
    required this.tipo,
    required this.unidad,
    required this.montoTotal,
    required this.saldoCapitalPendiente,
    required this.tieneInteres,
    this.tasaInteresMensual,
    this.interesDevengado = 0,
    this.interesPagado = 0,
    this.interesPendiente = 0,
    required this.estado,
    this.fechaSolicitud,
    this.fechaAprobacion,
    this.fechaRechazo,
    this.motivoRechazo,
    this.fechaFin,
    this.motivoCancelacion,
  });

  bool get isGrams => tipo.toLowerCase() == 'gramos';
}

class LoanInterestPeriodEntity {
  final String periodId;
  final int periodNumber;
  final DateTime? periodStart;
  final DateTime? dueDate;
  final double principalBase;
  final double interestAmount;
  final String status; // PENDING | PAID
  final DateTime? paidAt;

  LoanInterestPeriodEntity({
    required this.periodId,
    required this.periodNumber,
    this.periodStart,
    this.dueDate,
    this.principalBase = 0,
    this.interestAmount = 0,
    required this.status,
    this.paidAt,
  });
}

class LoanPaymentEntity {
  final String paymentId;
  final String paymentType; // INTEREST | PRINCIPAL
  final double amount;
  final DateTime? paidAt;
  final String? receiptUrl;
  final String? notes;

  LoanPaymentEntity({
    required this.paymentId,
    required this.paymentType,
    this.amount = 0,
    this.paidAt,
    this.receiptUrl,
    this.notes,
  });
}
