import 'package:front_gestion_minera/modules/treasury/domain/entity/entity.dart';

class SaleHistoryModel extends SaleHistoryEntity {
  SaleHistoryModel({
    required super.saleId,
    required super.saleCode,
    required super.fecha,
    required super.comprador,
    required super.pesoTotalKg,
    required super.pesoTotalG,
    required super.montoTotalBs,
    required super.estado,
  });

  factory SaleHistoryModel.fromJson(Map<String, dynamic> json) {
    return SaleHistoryModel(
      saleId: json['sale_id'] ?? '',
      saleCode: json['sale_code'] ?? '',
      fecha: DateTime.parse(json['fecha']),
      comprador: json['comprador'] ?? '',
      pesoTotalKg: (json['peso_total_kg'] ?? 0).toDouble(),
      pesoTotalG: (json['peso_total_g'] as num?)?.toDouble() ?? 0,
      montoTotalBs: (json['monto_total_bs'] as num?)?.toDouble() ?? 0,
      estado: json['estado'] ?? 'Completado',
    );
  }
}

class StatsSaleHistoryModel extends StatsSaleHistoryEntity {
  StatsSaleHistoryModel({
    required super.vendidoEsteMesKg,
    required super.vendidoEsteMesG,
    required super.variacionMesPct,
    required super.vendidoDelAnioKg,
    required super.vendidoDelAnioG,
    required super.totalPaginas,
    required super.totalRegistros,
  });

  factory StatsSaleHistoryModel.fromJson(Map<String, dynamic> json) {
    return StatsSaleHistoryModel(
      vendidoEsteMesKg: (json['vendido_este_mes_kg'] ?? 0).toDouble(),
      vendidoEsteMesG: (json['vendido_este_mes_g'] as num?)?.toDouble() ?? 0,
      variacionMesPct: json['variacion_mes_pct'] ?? '',
      vendidoDelAnioKg: (json['vendido_del_anio_kg'] ?? 0).toDouble(),
      vendidoDelAnioG: (json['vendido_del_anio_g'] as num?)?.toDouble() ?? 0,
      totalPaginas: (json['total_paginas'] ?? 0).toInt(),
      totalRegistros: (json['total_registros'] ?? 0).toInt()
    );
  }
}

class SaleHistoryResponseModel extends SaleHistoryResponseEntity {
  SaleHistoryResponseModel({
    required super.meta,
    required super.sales,
  });

  factory SaleHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return SaleHistoryResponseModel(
      meta: StatsSaleHistoryModel.fromJson(json['meta'] ?? {}),
      sales: (json['data'] as List<dynamic>? ?? [])
          .map((e) => SaleHistoryModel.fromJson(e))
          .toList(),
    );
  }
}
