import 'package:front_gestion_minera/modules/minutes_memos/domain/entity/create_memorandum_entity.dart';
import 'package:intl/intl.dart';

class CreateMemorandumModel extends CreateMemorandumEntity {
  CreateMemorandumModel({
    required super.title,
    required super.contenido,
    required super.date,
    required super.destinatary,
    required super.destinataryId,
    required super.attachmentIds,
  });

  factory CreateMemorandumModel.fromEntity(CreateMemorandumEntity entity) {
    return CreateMemorandumModel(
      title: entity.title,
      contenido: entity.contenido,
      date: entity.date,
      destinatary: entity.destinatary,
      destinataryId: entity.destinataryId,
      attachmentIds: entity.attachmentIds,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'contenido': contenido,
      'emission_date': DateFormat('yyyy-MM-dd').format(date),
      'destinatario_nombre': destinatary,
      'destinatario_member_id': destinataryId,
    };
  }
}
