class CreateMemorandumEntity {
  final String title;
  final String contenido;
  final DateTime date;
  final String destinatary;
  final String destinataryId;
  final List<String> attachmentIds;

  CreateMemorandumEntity({
    required this.title,
    required this.contenido,
    required this.date,
    required this.destinatary,
    required this.destinataryId,
    required this.attachmentIds,
  });
}
