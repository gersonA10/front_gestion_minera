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
    final dynamic destinatarioRaw = json['destinatario_nombre'];
    String? destinatario;
    if (destinatarioRaw is Map<String, dynamic>) {
      final nombre = destinatarioRaw['nombre'] as String? ?? '';
      final cargo = destinatarioRaw['cargo'] as String?;
      destinatario = cargo != null && cargo.isNotEmpty
          ? '$nombre ($cargo)'
          : nombre;
    } else if (destinatarioRaw is String) {
      destinatario = destinatarioRaw;
    }

    final dateRaw =
        json['created_at'] as String? ?? json['fecha'] as String? ?? '';
    final createdAt = DateTime.tryParse(dateRaw) ?? DateTime.now();

    return MemorandumModel(
      id: json['memo_id']?.toString() ?? '',
      numero: json['memo_number']?.toString() ?? '',
      asunto: json['title'] as String? ?? json['titulo'] as String? ?? '',
      destinatario: destinatario,
      createdAt: createdAt,
      estado: json['status'] as String? ?? '',
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
    final itemsList = json['items'] as List<dynamic>? ?? [];

    return MemorandosListModel(
      items: itemsList
          .map((e) => MemorandumModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: json['page'] as int? ?? 1,
      totalRecords: json['total'] as int? ?? 0,
      hasMoreData: json['hasMore'] as bool? ?? false,
    );
  }
}
