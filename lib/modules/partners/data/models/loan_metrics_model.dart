import '../../domain/entity/loan_metrics_entity.dart';

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

class LoanMetricsModel extends LoanMetricsEntity {
  LoanMetricsModel({required super.dinero, required super.gramos});

  factory LoanMetricsModel.fromJson(Map<String, dynamic> json) =>
      LoanMetricsModel(
        dinero: _unitFromJson(json["dinero"]),
        gramos: _unitFromJson(json["gramos"]),
      );

  static LoanMetricUnitEntity _unitFromJson(dynamic raw) {
    final json = (raw is Map<String, dynamic>) ? raw : <String, dynamic>{};
    return LoanMetricUnitEntity(
      totalPrestado: _toDouble(json["total_prestado"]),
      totalPagado: _toDouble(json["total_pagado"]),
      totalPendiente: _toDouble(json["total_pendiente"]),
      interesPagado: _toDouble(json["interes_pagado"]),
    );
  }
}
