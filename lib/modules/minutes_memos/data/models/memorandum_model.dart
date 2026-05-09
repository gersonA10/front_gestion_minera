
import '../../domain/entity/entity.dart';

class MemorandumModel extends MemorandumEntity {
  const MemorandumModel({
    required super.id,
    required super.numero,
    required super.asunto,
    super.destinatario,
    required super.createdAt,
    required super.estado,
  });

  factory MemorandumModel.fromJson(Map<String, dynamic> json) {
    final dynamic destinatarioRaw = json['destinatario'];
    String? destinatario;
    if (destinatarioRaw is Map<String, dynamic>) {
      final nombre = destinatarioRaw['nombre'] as String? ?? '';
      final cargo = destinatarioRaw['cargo'] as String?;
      destinatario = cargo != null && cargo.isNotEmpty ? '$nombre ($cargo)' : nombre;
    } else if (destinatarioRaw is String) {
      destinatario = destinatarioRaw;
    }

    final dateRaw = json['created_at'] as String? ?? json['fecha'] as String? ?? '';
    final createdAt = DateTime.tryParse(dateRaw) ?? DateTime.now();

    return MemorandumModel(
      id: json['id']?.toString() ?? '',
      numero: json['numero']?.toString() ?? '',
      asunto: json['asunto'] as String? ?? json['titulo'] as String? ?? '',
      destinatario: destinatario,
      createdAt: createdAt,
      estado: json['estado'] as String? ?? '',
    );
  }
}

class MemorandosListModel extends MemorandosListEntity {
  const MemorandosListModel({
    required super.items,
    required super.currentPage,
    required super.totalRecords,
    required super.hasMoreData,
  });

  factory MemorandosListModel.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    final dataList = json['data'] as List<dynamic>? ?? [];

    return MemorandosListModel(
      items: dataList
          .map((e) => MemorandumModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: meta['current_page'] as int? ?? 1,
      totalRecords: meta['total_records'] as int? ?? 0,
      hasMoreData: meta['has_more_data'] as bool? ?? false,
    );
  }
}
