
import '../../domain/entity/entity.dart';

class ActasCountModel extends ActasCountEntity {
  const ActasCountModel({
    required super.total,
    required super.finalizadas,
    required super.pendientes,
  });

  factory ActasCountModel.fromJson(Map<String, dynamic> json) {
    return ActasCountModel(
      total: json['total'] ?? 0,
      finalizadas: json['finalizadas'] ?? 0,
      pendientes: json['pendientes'] ?? 0,
    );
  }
}
