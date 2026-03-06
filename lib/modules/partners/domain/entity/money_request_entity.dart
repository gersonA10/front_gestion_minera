class MoneyRequestEntity {
  final String area;
  final String solicitante;
  final double monto;
  final String descripcion;
  final String? comprobantePath;

  MoneyRequestEntity({
    required this.area,
    required this.solicitante,
    required this.monto,
    required this.descripcion,
    this.comprobantePath,
  });
}