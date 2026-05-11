import 'package:front_gestion_minera/modules/minutes_memos/domain/entity/entity.dart';

class CreateActaModel extends CreateActaEntity {
  CreateActaModel({
    required super.title,
    required super.description,
    required super.date,
    required super.place,
    required super.participants,
    required super.attachmentIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'location': place,
      'emision_date': date.toIso8601String(),
      'participants': participants.map(
        (participant) => {
          'full_name': participant.fullName,
          'position': participant.rol,
          'attendance': participant.attendanceStatus,
        },
      ),
      'attachment_ids': attachmentIds,
    };
  }
}
