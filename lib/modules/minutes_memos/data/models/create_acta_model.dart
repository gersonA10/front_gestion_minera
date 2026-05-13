import 'package:front_gestion_minera/modules/minutes_memos/domain/entity/entity.dart';
import 'package:intl/intl.dart';

class CreateActaModel extends CreateActaEntity {
  CreateActaModel({
    required super.title,
    required super.description,
    required super.date,
    required super.place,
    required super.participants,
    required super.attachmentIds,
  });

  factory CreateActaModel.fromEntity(CreateActaEntity entity) {
    return CreateActaModel(
      title: entity.title,
      description: entity.description,
      date: entity.date,
      place: entity.place,
      participants: entity.participants,
      attachmentIds: entity.attachmentIds,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'location': place,
      'emision_date': DateFormat('yyyy-MM-dd').format(date),
      'participants': participants.map(
        (participant) => {
          'full_name': participant.fullName,
          'position': participant.rol,
          'attendance': participant.attendanceStatus,
        },
      ).toList(),
    };
  }
}
