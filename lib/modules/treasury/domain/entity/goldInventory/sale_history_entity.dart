class SaleHistoryEntity {
  String saleId;
  String saleCode;
  DateTime fecha;
  String comprador;
  double pesoTotalKg;
  int pesoTotalG;
  int montoTotalBs;
  String estado;

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
  double vendidoEsteMesKg;
  int vendidoEsteMesG;
  String variacionMesPct;
  double vendidoDelAnioKg;
  int vendidoDelAnioG;

  StatsSaleHistoryEntity({
    required this.vendidoEsteMesKg,
    required this.vendidoEsteMesG,
    required this.variacionMesPct,
    required this.vendidoDelAnioKg,
    required this.vendidoDelAnioG,
  });
}

class HistorySaleEntity {
  bool success;
  StatsSaleHistoryEntity meta;
  List<SaleHistoryEntity> data;

  HistorySaleEntity({
    required this.success,
    required this.meta,
    required this.data,
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
