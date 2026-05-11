import 'package:front_gestion_minera/modules/minutes_memos/domain/entity/entity.dart';

class CreateMemorandumModel extends CreateMemorandumEntity {
  CreateMemorandumModel({
    required super.title,
    required super.contenido,
    required super.date,
    required super.destinatary,
    required super.destinataryId,
    required super.attachmentIds,
  });

  Map<String, dynamic> toJson(){
    return {
      'title': title,
      'contenido': contenido,
      'emission_date': date.toIso8601String(),
      'destinatario_nombre': destinatary,
      'destinatario_member_id': destinataryId,
      'attachment_ids': attachmentIds,
    };
  }
}
