class SaleHistoryEntity {
  final String saleId;
  final String saleCode;
  final DateTime fecha;
  final String comprador;
  final double pesoTotalKg;
  final double pesoTotalG;
  final double montoTotalBs;
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
  final double vendidoEsteMesG;
  final String variacionMesPct;
  final double vendidoDelAnioKg;
  final double vendidoDelAnioG;
  final int totalPaginas;
  final int totalRegistros;

  StatsSaleHistoryEntity({
    required this.vendidoEsteMesKg,
    required this.vendidoEsteMesG,
    required this.variacionMesPct,
    required this.vendidoDelAnioKg,
    required this.vendidoDelAnioG,
    required this.totalPaginas,
    required this.totalRegistros,
  });
}

class SaleHistoryResponseEntity {
  final StatsSaleHistoryEntity meta;
  final List<SaleHistoryEntity> sales;

  SaleHistoryResponseEntity({
    required this.meta,
    required this.sales,
  });
}