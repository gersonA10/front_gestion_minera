class RequestDetailEntity {
  final String requestId;
  final DateTime fechaRegistro;
  final String solicitante;
  final String rol;
  final String descripcion;
  final double monto;
  final String evidenciaUrl;
  final String estadoVigilancia;
  final String estadoAdministracion;
  final DateTime? vigilanciaAprobadoEl;

  RequestDetailEntity({
    required this.requestId,
    required this.fechaRegistro,
    required this.solicitante,
    required this.rol,
    required this.descripcion,
    required this.monto,
    required this.evidenciaUrl,
    required this.estadoVigilancia,
    required this.estadoAdministracion,
    this.vigilanciaAprobadoEl,
  });
}