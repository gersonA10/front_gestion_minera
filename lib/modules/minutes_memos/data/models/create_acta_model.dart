import 'dart:convert';

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
      'emission_date': DateFormat('yyyy-MM-dd').format(date),
      // El backend espera `participants` como string JSON dentro del
      // multipart/form-data (lo hace JSON.parse). Enviar la lista cruda hace
      // que Dio la serialice con .toString() de Dart y el parse falle.
      'participants': jsonEncode(
        participants
            .map(
              (participant) => {
                'member_id': participant.memberId,
                'position': participant.rol,
                'attendance': participant.attendanceStatus,
              },
            )
            .toList(),
      ),
    };
  }
}
