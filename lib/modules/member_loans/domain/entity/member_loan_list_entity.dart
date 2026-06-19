/// Préstamo de socio en la bandeja de Hacienda (GET /api/treasury/members/loans).
class MemberLoanListItemEntity {
  final String loanId;
  final String socio;
  final String tipo; // "Dinero" | "Gramos"
  final String loanType; // MONEY | GRAMS
  final double montoOGramos;
  final double? capitalPendiente;
  final bool hasInterest;
  final double? tasaInteresMensual;
  final String estado; // "En Revisión" | "Vigente" | "Pagado" | ...
  final String status; // PENDING | APPROVED | PAID | REJECTED | CANCELLED
  final DateTime? createdAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? rejectReason;
  final DateTime? endDate;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final double interesPagado;

  MemberLoanListItemEntity({
    required this.loanId,
    required this.socio,
    required this.tipo,
    required this.loanType,
    required this.montoOGramos,
    this.capitalPendiente,
    this.hasInterest = false,
    this.tasaInteresMensual,
    required this.estado,
    required this.status,
    this.createdAt,
    this.approvedAt,
    this.rejectedAt,
    this.rejectReason,
    this.endDate,
    this.cancelledAt,
    this.cancellationReason,
    this.interesPagado = 0,
  });

  bool get isGrams =>
      loanType.toUpperCase() == 'GRAMS' || tipo.toLowerCase() == 'gramos';
}

/// Página de la bandeja (data + meta).
class MemberLoanPageEntity {
  final List<MemberLoanListItemEntity> items;
  final bool hasMore;
  final int totalRecords;

  MemberLoanPageEntity({
    required this.items,
    required this.hasMore,
    this.totalRecords = 0,
  });
}
