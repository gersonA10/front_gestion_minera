class CreateMaintenanceRequestEntity {
  final String machineId;
  final String failureType;
  final String estimatedAmount;
  final String priority;
  final String description;
  final String evidenceUrlPath;

  const CreateMaintenanceRequestEntity({
    required this.machineId,
    required this.failureType,
    required this.estimatedAmount,
    required this.priority,
    required this.description,
    required this.evidenceUrlPath,
  });
}
class CreateMaintenanceResponseEntity {
  final String maintenanceId;
  final String requestId;

  const CreateMaintenanceResponseEntity({
    required this.maintenanceId,
    required this.requestId,
  });
}
