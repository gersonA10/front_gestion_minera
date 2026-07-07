/// Caja de tesorería (GET /api/treasury/cash-registers) para el selector.
class CashRegisterEntity {
  final String id;
  final String nombre;
  final double saldoDisponible;

  CashRegisterEntity({
    required this.id,
    required this.nombre,
    this.saldoDisponible = 0,
  });
}
