class ActaEntity {
  final String id;
  final String numero;
  final String titulo;
  final String? descripcion;
  final String? ubicacion;
  final int? totalParticipantes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String estado;

  const ActaEntity({
    required this.id,
    required this.numero,
    required this.titulo,
    this.descripcion,
    this.ubicacion,
    this.totalParticipantes,
    required this.createdAt,
    this.updatedAt,
    required this.estado,
  });
}

class ActasListEntity {
  final List<ActaEntity> items;
  final int total;
  final int page;
  final bool hasMore;

  const ActasListEntity({
    required this.items,
    required this.total,
    required this.page,
    required this.hasMore,
  });
}
