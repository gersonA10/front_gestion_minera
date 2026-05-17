class ActaDetailEntity {
  final String actaId;
  final String numero;
  final String titulo;
  final String? descripcion;
  final String? ubicacion;
  final String estado;
  final DateTime fechaEmision;
  final List<ActaParticipantEntity> participants;
  final List<ActaAttachmentEntity> attachments;

  const ActaDetailEntity({
    required this.actaId,
    required this.numero,
    required this.titulo,
    this.descripcion,
    this.ubicacion,
    required this.estado,
    required this.fechaEmision,
    required this.participants,
    required this.attachments,
  });
}

class ActaParticipantEntity {
  final String? memberId;
  final String fullName;
  final String? position;
  final String attendanceStatus;

  const ActaParticipantEntity({
    this.memberId,
    required this.fullName,
    this.position,
    required this.attendanceStatus,
  });
}

class ActaAttachmentEntity {
  final String attachmentId;
  final String nombreArchivo;
  final String tipoArchivo;
  final String pesoArchivo;
  final String url;

  const ActaAttachmentEntity({
    required this.attachmentId,
    required this.nombreArchivo,
    required this.tipoArchivo,
    required this.pesoArchivo,
    required this.url,
  });
}
