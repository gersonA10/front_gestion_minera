import '../../domain/entity/entity.dart';

class MemorandumDetailModel extends MemorandumDetailEntity {
  const MemorandumDetailModel({
    required super.memoId,
    required super.numero,
    required super.titulo,
    required super.contenido,
    required super.fechaEmision,
    super.destinatarioNombre,
    required super.attachments,
  });

  factory MemorandumDetailModel.fromJson(
    Map<String, dynamic>? json,
  ) {

    final data = json ?? {};

    final attachmentsRaw = data['attachments'];

    return MemorandumDetailModel(
      memoId: data['memo_id']?.toString() ?? '',

      numero: data['memo_number']?.toString() ?? '',

      titulo: data['title']?.toString() ?? '',

      contenido: data['contenido']?.toString() ?? '',

      fechaEmision:
          DateTime.tryParse(
            data['emission_date']?.toString() ?? '',
          ) ??
          DateTime.now(),

      destinatarioNombre:
          data['destinatario_nombre']?.toString(),

      attachments:
          attachmentsRaw is List
              ? attachmentsRaw
                    .where((e) => e != null)
                    .map(
                      (attachment) =>
                          MemorandumAttachmentModel.fromJson(
                            Map<String, dynamic>.from(
                              attachment as Map,
                            ),
                          ),
                    )
                    .toList()
              : [],
    );
  }
}

class MemorandumAttachmentModel
    extends MemorandumAttachmentEntity {
  const MemorandumAttachmentModel({
    required super.attachmentId,
    required super.nombreArchivo,
    required super.tipoArchivo,
    required super.pesoArchivo,
    required super.url,
  });

  factory MemorandumAttachmentModel.fromJson(
    Map<String, dynamic>? json,
  ) {

    final data = json ?? {};

    return MemorandumAttachmentModel(
      attachmentId:
          data['attachment_id']?.toString() ?? '',

      nombreArchivo:
          data['file_name']?.toString() ?? '',

      tipoArchivo:
          data['file_type']?.toString() ?? '',

      pesoArchivo:
          data['file_size']?.toString() ?? '',

      url:
          data['url']?.toString() ?? '',
    );
  }
}