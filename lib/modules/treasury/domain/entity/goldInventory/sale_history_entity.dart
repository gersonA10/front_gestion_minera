class SaleHistoryEntity {
  final String saleId;
  final String saleCode;
  final DateTime fecha;
  final String comprador;
  final double pesoTotalKg;
  final int pesoTotalG;
  final int montoTotalBs;
  final String estado;

  SaleHistoryEntity({
    required this.saleId,
    required this.saleCode,
    required this.fecha,
    required this.comprador,
    required this.pesoTotalKg,
    required this.pesoTotalG,
    required this.montoTotalBs,
    required this.estado,
  });
}

class StatsSaleHistoryEntity {
  final double vendidoEsteMesKg;
  final int vendidoEsteMesG;
  final String variacionMesPct;
  final double vendidoDelAnioKg;
  final int vendidoDelAnioG;

  StatsSaleHistoryEntity({
    required this.vendidoEsteMesKg,
    required this.vendidoEsteMesG,
    required this.variacionMesPct,
    required this.vendidoDelAnioKg,
    required this.vendidoDelAnioG,
  });
}

class PaginatedSalesHistoryEntity {
  final List<SaleHistoryEntity> sales;
  final bool hashMore;
  final int totalRegistros;

  PaginatedSalesHistoryEntity({
    required this.sales,
    required this.hashMore,
    required this.totalRegistros,
  });
}
