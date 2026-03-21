class DetailsofanapplicationResponseEntity {
  final bool success;
  final String message;
  final DetailsofanapplicationDataEntity data;

  DetailsofanapplicationResponseEntity({
    required this.success,
    required this.message,
    required this.data,
  });
}

class DetailsofanapplicationDataEntity {
  final String requestId;
  final int monto;
  final String descripcion;
  final String solicitante;
  final DateTime createdAt;
  final List<FlujoAprobacionEntity> flujoAprobacion;
  final String evidenciaUrl;

  DetailsofanapplicationDataEntity({
    required this.requestId,
    required this.monto,
    required this.descripcion,
    required this.solicitante,
    required this.createdAt,
    required this.flujoAprobacion,
    required this.evidenciaUrl,
  });
}

class FlujoAprobacionEntity {
  final String etapa;
  final String aprobador;
  final DateTime fecha;

  FlujoAprobacionEntity({
    required this.etapa,
    required this.aprobador,
    required this.fecha,
  });
}
