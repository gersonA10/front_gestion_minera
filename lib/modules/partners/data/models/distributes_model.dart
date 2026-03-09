
import '../../domain/entity/entity.dart';

class DistributesMetricsModel extends DistributesMetricsEntity {
  DistributesMetricsModel({
    required super.totalDistribuido,
    required super.totalPagado,
    required super.totalPendiente,
  });

  factory DistributesMetricsModel.fromJson(Map<String, dynamic> json) {
    return DistributesMetricsModel(
      totalDistribuido: double.tryParse(json['total_distribuido']?.toString() ?? '0') ?? 0.0,
      totalPagado: double.tryParse(json['total_pagado']?.toString() ?? '0') ?? 0.0,
      totalPendiente: double.tryParse(json['total_pendiente']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class DistributesHistoryModel extends DistributesHistoryEntity {
  DistributesHistoryModel({
    required super.description,
    required super.registeredDate,
    required super.amount,
    required super.status,
  });

  factory DistributesHistoryModel.fromJson(Map<String, dynamic> json) {
    return DistributesHistoryModel(
      description: json['description'] ?? 'Sin descripción',
      registeredDate: DateTime.tryParse(json['registered_date'] ?? '') ?? DateTime.now(),
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'Pendiente',
    );
  }

  DistributesHistoryEntity toEntity() {
    return DistributesHistoryEntity(
      description: description,
      registeredDate: registeredDate,
      amount: amount,
      status: status,
    );
  }
}