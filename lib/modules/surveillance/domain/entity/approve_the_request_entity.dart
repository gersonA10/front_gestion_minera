class ApproveTheRequestEntity {
  final bool success;
  final String message;
  final ApproveTheRequestDataEntity data;

  ApproveTheRequestEntity({
    required this.success,
    required this.message,
    required this.data,
  });
}

class ApproveTheRequestDataEntity {
  final String description;

  ApproveTheRequestDataEntity({required this.description});
}
