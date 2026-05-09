class MemorandumEntity {
  final String id;
  final String numero;
  final String asunto;
  final String? destinatario;
  final DateTime createdAt;
  final String estado;

  const MemorandumEntity({
    required this.id,
    required this.numero,
    required this.asunto,
    this.destinatario,
    required this.createdAt,
    required this.estado,
  });
}

class MemorandosListEntity {
  final List<MemorandumEntity> items;
  final int currentPage;
  final int totalRecords;
  final bool hasMoreData;

  const MemorandosListEntity({
    required this.items,
    required this.currentPage,
    required this.totalRecords,
    required this.hasMoreData,
  });
}
