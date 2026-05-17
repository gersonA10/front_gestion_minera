import '../../domain/entity/acta_detail_entity.dart';

class ActaDetailModel extends ActaDetailEntity {
  const ActaDetailModel({
    required super.actaId,
    required super.numero,
    required super.titulo,
    super.descripcion,
    super.ubicacion,
    required super.estado,
    required super.fechaEmision,
    required super.participants,
    required super.attachments,
  });

  factory ActaDetailModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};

    final participantsRaw = data['participants'];
    final attachmentsRaw = data['attachments'];

    return ActaDetailModel(
      actaId: data['record_id']?.toString() ?? '',
      numero: data['record_number']?.toString() ?? '',
      titulo: data['title']?.toString() ?? '',
      descripcion: data['description']?.toString(),
      ubicacion: data['location']?.toString(),
      estado: data['status']?.toString() ?? '',
      fechaEmision:
          DateTime.tryParse(data['emission_date']?.toString() ?? '') ??
          DateTime.tryParse(data['created_at']?.toString() ?? '') ??
          DateTime.now(),
      participants: participantsRaw is List
          ? participantsRaw
              .where((e) => e != null)
              .map((e) => ActaParticipantModel.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList()
          : [],
      attachments: attachmentsRaw is List
          ? attachmentsRaw
              .where((e) => e != null)
              .map((e) => ActaAttachmentModel.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList()
          : [],
    );
  }
}

class ActaParticipantModel extends ActaParticipantEntity {
  const ActaParticipantModel({
    super.memberId,
    required super.fullName,
    super.position,
    required super.attendanceStatus,
  });

  factory ActaParticipantModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};
    return ActaParticipantModel(
      memberId: data['member_id']?.toString(),
      fullName: data['full_name']?.toString() ?? '',
      position: data['position']?.toString(),
      attendanceStatus: data['attendance']?.toString() ?? '',
    );
  }
}

class ActaAttachmentModel extends ActaAttachmentEntity {
  const ActaAttachmentModel({
    required super.attachmentId,
    required super.nombreArchivo,
    required super.tipoArchivo,
    required super.pesoArchivo,
    required super.url,
  });

  factory ActaAttachmentModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};
    return ActaAttachmentModel(
      attachmentId: data['attachment_id']?.toString() ?? '',
      nombreArchivo: data['file_name']?.toString() ?? '',
      tipoArchivo: data['file_type']?.toString() ?? '',
      pesoArchivo: data['file_size']?.toString() ?? '',
      url: data['url']?.toString() ?? '',
    );
  }
}
