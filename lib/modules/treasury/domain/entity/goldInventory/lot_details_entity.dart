class LotDetailsResponseEntity {
  final bool success;
  final LotDetailsDataEntity data;
  LotDetailsResponseEntity({required this.success, required this.data});
}

class LotDetailsDataEntity {
  final String batchCode;
  final int progresoConsumoPct;
  final double pesoInicial;
  final double pesoVendido;
  final double pesoDisponible;
  final DetallesExtraccionEntity detallesExtraccion;
  final String observaciones;
  final String evidenciaUrl;
  final List<HistorialMovimientoEntity> historialMovimientos;
  final ResumenFinancieroEntity resumenFinanciero;

  LotDetailsDataEntity({
    required this.batchCode,
    required this.progresoConsumoPct,
    required this.pesoInicial,
    required this.pesoVendido,
    required this.pesoDisponible,
    required this.detallesExtraccion,
    required this.observaciones,
    required this.evidenciaUrl,
    required this.historialMovimientos,
    required this.resumenFinanciero,
  });
}

class DetallesExtraccionEntity {
  final DateTime fecha;
  final String responsable;

  DetallesExtraccionEntity({required this.fecha, required this.responsable});
}

class HistorialMovimientoEntity {
  final String tipo;
  final DateTime fecha;
  final String monto;

  HistorialMovimientoEntity({
    required this.tipo,
    required this.fecha,
    required this.monto,
  });
}

class ResumenFinancieroEntity {
  final double totalVendidoBs;
  final int ventasTotales;
  final double precioPromedio;

  ResumenFinancieroEntity({
    required this.totalVendidoBs,
    required this.ventasTotales,
    required this.precioPromedio,
  });
}

///
class LotDetailsRequestEntity {
  final String saleDate;
  final String buyer;
  final double totalGramsSold;
  final double priceUsdPerGram;
  final String comprobante;

  LotDetailsRequestEntity({
    required this.saleDate,
    required this.buyer,
    required this.totalGramsSold,
    required this.priceUsdPerGram,
    required this.comprobante,
  });
}
