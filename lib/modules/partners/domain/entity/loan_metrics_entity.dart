/// Métricas del socio (GET /api/loans/metrics): un bloque por unidad.
class LoanMetricsEntity {
  final LoanMetricUnitEntity dinero;
  final LoanMetricUnitEntity gramos;

  LoanMetricsEntity({required this.dinero, required this.gramos});
}

class LoanMetricUnitEntity {
  final double totalPrestado; // capital aprobado + pagado
  final double totalPagado;
  final double totalPendiente; // capital aún vigente
  final double interesPagado; // interés acumulado en su unidad

  LoanMetricUnitEntity({
    this.totalPrestado = 0,
    this.totalPagado = 0,
    this.totalPendiente = 0,
    this.interesPagado = 0,
  });
}
