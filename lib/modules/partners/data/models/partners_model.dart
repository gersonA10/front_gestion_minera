import 'dart:convert';
import '../../domain/entity/entity.dart';

// MODELO DE MÉTRICAS
class ContributionMetricsModel extends ContributionMetricsEntity {
  ContributionMetricsModel({
    required super.totalAportado,
    required super.totalConfirmado,
    required super.totalPendiente,
  });

  factory ContributionMetricsModel.fromJson(Map<String, dynamic> json) {
    return ContributionMetricsModel(
      totalAportado: double.tryParse(json['total_aportado']?.toString() ?? '0') ?? 0.0,
      totalConfirmado: double.tryParse(json['total_confirmado']?.toString() ?? '0') ?? 0.0,
      totalPendiente: double.tryParse(json['total_pendiente']?.toString() ?? '0') ?? 0.0,
    );
  }
}

// MODELO DE HISTORIAL
ContributeHistoryResponseModel loanHistoryResponseFromJson(String str) =>
    ContributeHistoryResponseModel.fromJson(json.decode(str));

class ContributeHistoryResponseModel extends ContributeHistoryResponseEntity {
  ContributeHistoryResponseModel({
    required super.success,
    required super.message,
    required super.data,
  });

  factory ContributeHistoryResponseModel.fromJson(Map<String, dynamic> json) =>
      ContributeHistoryResponseModel(
        success: json["success"] ?? false,
        message: json["message"] ?? '',
        data: json["data"] != null 
            ? List<ContributeHistoryDataModel>.from(
                json["data"].map((x) => ContributeHistoryDataModel.fromJson(x)),
              )
            : [],
      );
}

class ContributeHistoryDataModel extends ContributeHistoryDataEntity {
  ContributeHistoryDataModel({
    required super.detailId,
    required super.motivo,
    required super.monto,
    required super.estado,
    required super.fechaPago,
  });

  factory ContributeHistoryDataModel.fromJson(Map<String, dynamic> json) =>
      ContributeHistoryDataModel(
        detailId: json["detail_id"] ?? '',
        motivo: json["motivo"] ?? 'Sin motivo',
        monto: double.tryParse(json["monto"]?.toString() ?? '0') ?? 0.0,
        estado: json["estado"] ?? 'Desconocido',
        fechaPago: DateTime.tryParse(json["fecha_pago"] ?? ''),
      );
}