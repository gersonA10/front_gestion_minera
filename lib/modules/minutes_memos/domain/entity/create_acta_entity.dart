class CreateActaEntity {
  final String title;
  final String description;
  final DateTime date;
  final String place;
  final List<ParticipantEntity> participants;
  final List<String> attachmentIds;

  CreateActaEntity({
    required this.title,
    required this.description,
    required this.date,
    required this.place,
    required this.participants,
    required this.attachmentIds,
  });
}

class ParticipantEntity {
  final String fullName;
  final String? rol;
  final String attendanceStatus;

  ParticipantEntity({
    required this.fullName,
    required this.rol,
    required this.attendanceStatus,
  });
}
