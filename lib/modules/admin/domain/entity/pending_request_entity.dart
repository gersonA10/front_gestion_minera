class PendingRequestEntity {
  final String requestId;
  final DateTime fechaRegistro;
  final String solicitante;
  final String rol;
  final String descripcion;
  final double monto;
  final String evidenciaUrl;
  final String estadoVigilancia;

  PendingRequestEntity({
    required this.requestId,
    required this.fechaRegistro,
    required this.solicitante,
    required this.rol,
    required this.descripcion,
    required this.monto,
    required this.evidenciaUrl,
    required this.estadoVigilancia,
  });

  String get initials {
    final parts = solicitante.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return solicitante.isNotEmpty
        ? solicitante.substring(0, solicitante.length.clamp(0, 2)).toUpperCase()
        : '??';
  }
}

class PaginatedPendingRequestEntity {
  final List<PendingRequestEntity> items;
  final bool hasMoreData;
  final int totalRecords;

  PaginatedPendingRequestEntity({
    required this.items,
    required this.hasMoreData,
    required this.totalRecords,
  });
}
