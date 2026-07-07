class MemberInboxResponseEntity {
  final bool success;
  final String message;
  final List<MemberInboxItemEntity> data;

  MemberInboxResponseEntity({
    required this.success,
    required this.message,
    required this.data,
  });
}

class MemberInboxItemEntity {
  final String id;

  /// 'memorando' | 'reunion'
  final String type;
  final String title;

  /// Estado crudo del backend: 'PENDIENTE' | 'FINALIZADO'
  final String status;
  final DateTime? date;
  final String? fileUrl;

  /// Para memorando: remitente ("De:"). Para reunión: responsable ("Resp:").
  final String? person;
  final bool personIsResp;

  /// Solo presente en reuniones.
  final String? location;

  MemberInboxItemEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.status,
    required this.date,
    required this.fileUrl,
    required this.person,
    required this.personIsResp,
    required this.location,
  });
}
