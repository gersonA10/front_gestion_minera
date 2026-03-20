
import '../../domain/entity/entity.dart';

class TreasuryMetricsModel extends TreasuryMetricsEntity {
  TreasuryMetricsModel({
    required super.pendientes,
    required super.activos,
  });

  factory TreasuryMetricsModel.fromJson(Map<String, dynamic> json) {
    return TreasuryMetricsModel(
      pendientes: json['pendientes'] ?? 0,
      activos: json['activos'] ?? 0,
    );
  }
}