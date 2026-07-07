/// Un préstamo del socio en el historial (GET /api/loans/history).
class LoanHistoryDataEntity {
  final String loanId;
  final String loanType; // "Dinero" | "Gramos"
  final double amountOrQuantity; // Bs o gramos según el tipo
  final String description;
  final String fileUrl;
  final String status; // "En Revisión" | "Vigente" | "Pagado" | "Rechazado" | "Cancelado"
  final String? motivoRechazo;
  final bool hasInterest;
  final double? interestRate; // % mensual (dinero) o gramos/mes (gramos)
  final DateTime? approvedAt;
  final DateTime? endDate;
  final double? outstandingPrincipal; // capital pendiente
  final String? motivoCancelacion;
  final double interesPagado;
  final DateTime createdAt;

  LoanHistoryDataEntity({
    required this.loanId,
    required this.loanType,
    required this.amountOrQuantity,
    required this.description,
    required this.fileUrl,
    required this.status,
    this.motivoRechazo,
    this.hasInterest = false,
    this.interestRate,
    this.approvedAt,
    this.endDate,
    this.outstandingPrincipal,
    this.motivoCancelacion,
    this.interesPagado = 0,
    required this.createdAt,
  });

  bool get isGrams => loanType.toLowerCase() == 'gramos';
}

/// Página de historial con bandera de paginación (meta.has_more_data).
class LoanHistoryPageEntity {
  final List<LoanHistoryDataEntity> items;
  final bool hasMore;

  LoanHistoryPageEntity({required this.items, required this.hasMore});
}
