/// Detalle de un préstamo de socio para Hacienda (GET /api/treasury/members/loans/:id).
class MemberLoanDetailEntity {
  final MemberLoanDetailHeaderEntity cabecera;
  final List<MemberLoanInterestPeriodEntity> cronogramaInteres;
  final List<MemberLoanPaymentEntity> pagos;

  MemberLoanDetailEntity({
    required this.cabecera,
    required this.cronogramaInteres,
    required this.pagos,
  });
}

class MemberLoanDetailHeaderEntity {
  final String loanId;
  final String socio;
  final String? identificacion;
  final String? telefono;
  final String tipo; // "Dinero" | "Gramos"
  final String unidad; // "Bs" | "g"
  final double montoTotal;
  final double capitalPendiente;
  final double capitalPagado;
  final bool tieneInteres;
  final double? tasaInteresMensual;
  final double interesDevengado;
  final double interesPagado;
  final double interesPendiente;
  final String estado; // PENDING | APPROVED | PAID | REJECTED | CANCELLED
  final int vecesPrestoSocio;
  final DateTime? fechaSolicitud;
  final DateTime? fechaAprobacion;
  final DateTime? fechaRechazo;
  final String? motivoRechazo;
  final DateTime? fechaFin;
  final DateTime? fechaCancelacion;
  final String? motivoCancelacion;
  final String? comprobanteUrl;

  /// Solo en gramos: código del lote creado en bóveda al aprobar (ej. PRE-2026-0001).
  final String? loteGenerado;

  MemberLoanDetailHeaderEntity({
    required this.loanId,
    required this.socio,
    this.identificacion,
    this.telefono,
    required this.tipo,
    required this.unidad,
    required this.montoTotal,
    this.capitalPendiente = 0,
    this.capitalPagado = 0,
    this.tieneInteres = false,
    this.tasaInteresMensual,
    this.interesDevengado = 0,
    this.interesPagado = 0,
    this.interesPendiente = 0,
    required this.estado,
    this.vecesPrestoSocio = 0,
    this.fechaSolicitud,
    this.fechaAprobacion,
    this.fechaRechazo,
    this.motivoRechazo,
    this.fechaFin,
    this.fechaCancelacion,
    this.motivoCancelacion,
    this.comprobanteUrl,
    this.loteGenerado,
  });

  bool get isGrams => tipo.toLowerCase() == 'gramos';
  bool get isPending => estado.toUpperCase() == 'PENDING';
  bool get isApproved => estado.toUpperCase() == 'APPROVED';
}

class MemberLoanInterestPeriodEntity {
  final String periodId;
  final int periodNumber;
  final DateTime? periodStart;
  final DateTime? dueDate;
  final double principalBase;
  final double interestAmount;
  final String status; // PENDING | PAID
  final DateTime? paidAt;

  MemberLoanInterestPeriodEntity({
    required this.periodId,
    required this.periodNumber,
    this.periodStart,
    this.dueDate,
    this.principalBase = 0,
    this.interestAmount = 0,
    required this.status,
    this.paidAt,
  });

  bool get isPaid => status.toUpperCase() == 'PAID';
}

class MemberLoanPaymentEntity {
  final String paymentId;
  final String paymentType; // INTEREST | PRINCIPAL
  final String? periodId;
  final double amount;
  final DateTime? paidAt;
  final String? receiptUrl;
  final String? notes;
  final String? cashRegisterId;
  final String? transactionId;

  MemberLoanPaymentEntity({
    required this.paymentId,
    required this.paymentType,
    this.periodId,
    this.amount = 0,
    this.paidAt,
    this.receiptUrl,
    this.notes,
    this.cashRegisterId,
    this.transactionId,
  });

  bool get isInterest => paymentType.toUpperCase() == 'INTEREST';
}
