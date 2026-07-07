
import '../../domain/entity/entity.dart';

class ActaModel extends ActaEntity {
  const ActaModel({
    required super.id,
    required super.numero,
    required super.titulo,
    super.descripcion,
    super.ubicacion,
    super.totalParticipantes,
    required super.createdAt,
    super.updatedAt,
    required super.estado,
  });

  factory ActaModel.fromJson(Map<String, dynamic> json) {
    final dateRaw = json['created_at'] as String? ?? json['fecha'] as String? ?? '';
    final updatedRaw = json['updated_at'] as String?;

    return ActaModel(
      id: json['record_id']?.toString() ?? '',
      numero: json['record_number']?.toString() ?? '',
      titulo: json['title'] as String? ?? json['asunto'] as String? ?? '',
      descripcion: json['description'] as String?,
      ubicacion: json['location'] as String?,
      totalParticipantes: json['participants_count'] as int?,
      createdAt: DateTime.tryParse(dateRaw) ?? DateTime.now(),
      updatedAt: updatedRaw != null ? DateTime.tryParse(updatedRaw) : null,
      estado: json['status'] as String? ?? '',
    );
  }
}

class ActasListModel extends ActasListEntity {
  const ActasListModel({
    required super.items,
    required super.total,
    required super.page,
    required super.hasMore,
  });

  factory ActasListModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];

    return ActasListModel(
      items: itemsList
          .map((e) => ActaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}
