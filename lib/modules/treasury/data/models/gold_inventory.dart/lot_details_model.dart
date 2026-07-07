
import '../../../domain/entity/entity.dart';

class LotDetailsResponseModel extends LotDetailsResponseEntity {
  LotDetailsResponseModel({required super.success, required super.data,});

  factory LotDetailsResponseModel.fromJson(Map<String, dynamic> json) =>
      LotDetailsResponseModel(
        success: json["success"],
        data: LotDetailsDataModel.fromJson(json["data"]),
      
      );
}

class LotDetailsDataModel extends LotDetailsDataEntity {
  LotDetailsDataModel({
    required super.batchCode,
    required super.progresoConsumoPct,
    required super.pesoInicial,
    required super.pesoVendido,
    required super.pesoDisponible,
    required super.detallesExtraccion,
    required super.observaciones,
    required super.evidenciaUrl,
    required super.historialMovimientos,
    required super.resumenFinanciero,
  });

  factory LotDetailsDataModel.fromJson(Map<String, dynamic> json) =>
      LotDetailsDataModel(
        batchCode: json["batch_code"],
        progresoConsumoPct: json["progreso_consumo_pct"],
        pesoInicial: (json["peso_inicial"]  as num).toDouble(),
        pesoVendido: (json["peso_vendido"]  as num).toDouble(),
        pesoDisponible: (json["peso_disponible"]  as num).toDouble(),
        detallesExtraccion: DetallesExtraccionModel.fromJson(
          json["detalles_extraccion"],
        ),
        observaciones: json["observaciones"],
        evidenciaUrl: json["evidencia_url"]??'',
        historialMovimientos: List<HistorialMovimientoModel>.from(
          json["historial_movimientos"].map(
            (x) => HistorialMovimientoModel.fromJson(x),
          ),
        ),
        resumenFinanciero: ResumenFinancieroModel.fromJson(
          json["resumen_financiero"],
        ),
      );
}

class DetallesExtraccionModel extends DetallesExtraccionEntity {
  DetallesExtraccionModel({required super.fecha, required super.responsable});

  factory DetallesExtraccionModel.fromJson(Map<String, dynamic> json) =>
      DetallesExtraccionModel(
        fecha: DateTime.parse(json["fecha"]),
        responsable: json["responsable"],
      );
}

class HistorialMovimientoModel extends HistorialMovimientoEntity {
  HistorialMovimientoModel({
    required super.tipo,
    required super.fecha,
    required super.monto,
  });

  factory HistorialMovimientoModel.fromJson(Map<String, dynamic> json) =>
      HistorialMovimientoModel(
        tipo: json["tipo"],
        fecha: DateTime.parse(json["fecha"]),
        monto: json["monto"],
      );
}

class ResumenFinancieroModel extends ResumenFinancieroEntity {
  ResumenFinancieroModel({
    required super.totalVendidoBs,
    required super.ventasTotales,
    required super.precioPromedio,
  });

  factory ResumenFinancieroModel.fromJson(Map<String, dynamic> json) =>
      ResumenFinancieroModel(
        totalVendidoBs: (json["total_vendido_bs"] as num).toDouble(),
        ventasTotales: json["ventas_totales"],
        precioPromedio: (json["precio_promedio"] as num).toDouble(),
      );
}

///
class LotDetailsRequestModel extends LotDetailsRequestEntity {
  LotDetailsRequestModel({
    required super.saleDate,
    required super.buyer,
    required super.totalGramsSold,
    required super.priceUsdPerGram,
    required super.comprobante,
  });

  factory LotDetailsRequestModel.fromJson(Map<String, dynamic> json) {
    return LotDetailsRequestModel(
      saleDate: json['sale_date'],
      buyer: json['buyer'],
      totalGramsSold: json['total_grams_sold'] .toDouble(),
      priceUsdPerGram: json['price_usd_per_gram'] .toDouble(),
      comprobante: json['comprobante'],
    );
  }

  LotDetailsRequestEntity toEntity() {
    return LotDetailsRequestEntity(
      saleDate: saleDate,
      buyer: buyer,
      totalGramsSold: totalGramsSold,
      priceUsdPerGram: priceUsdPerGram,
      comprobante: comprobante,
    );
  }
}