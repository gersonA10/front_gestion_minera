import '../../domain/entity/entity.dart';

class MemosCountModel extends MemosCountEntity {
  const MemosCountModel({
    required super.total,
    required super.finalizadas,
    required super.pendientes,
  });

  factory MemosCountModel.fromJson(Map<String, dynamic> json) {
    return MemosCountModel(
      total: json['total'] ?? 0,
      finalizadas: json['finalizadas'] ?? 0,
      pendientes: json['pendientes'] ?? 0,
    );
  }
}
