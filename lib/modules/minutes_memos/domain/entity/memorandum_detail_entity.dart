class MemorandumDetailEntity {
  final String memoId;
  final String numero;
  final String titulo;
  final String contenido;
  final DateTime fechaEmision;
  final String? destinatarioNombre;
  final List<MemorandumAttachmentEntity> attachments;

  const MemorandumDetailEntity({
    required this.memoId,
    required this.numero,
    required this.titulo,
    required this.contenido,
    required this.fechaEmision,
    this.destinatarioNombre,
    required this.attachments,
  });
}

class MemorandumAttachmentEntity {
  final String attachmentId;
  final String nombreArchivo;
  final String tipoArchivo;
  final String pesoArchivo;
  final String url;

  const MemorandumAttachmentEntity({
    required this.attachmentId,
    required this.nombreArchivo,
    required this.tipoArchivo,
    required this.pesoArchivo,
    required this.url,
  });
}
