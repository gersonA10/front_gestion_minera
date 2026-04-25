import 'package:front_gestion_minera/modules/machinery/domain/entity/create_maintenance_response_entity.dart';

class CreateMaintenanceRequestModel extends CreateMaintenanceRequestEntity {
  const CreateMaintenanceRequestModel({
    required super.machineId,
    required super.failureType,
    required super.estimatedAmount,
    required super.description,
    required super.evidenceUrlPath,
  });
  factory CreateMaintenanceRequestModel.fromEntity(
    CreateMaintenanceRequestEntity entity,
  ) {
    return CreateMaintenanceRequestModel(
      machineId: entity.machineId,
      failureType: entity.failureType,
      estimatedAmount: entity.estimatedAmount,
      description: entity.description,
      evidenceUrlPath: entity.evidenceUrlPath,
    );
  }
  Map<String, dynamic> toFormDataMap() {
    return {
      'machine_id': machineId,
      'failure_type': failureType,
      'estimated_amount': estimatedAmount,
      'description': description,
    };
  }
}

class CreateMaintenanceResponseModel extends CreateMaintenanceResponseEntity {
  const CreateMaintenanceResponseModel({
    required super.maintenanceId,
    required super.requestId,
  });

  factory CreateMaintenanceResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateMaintenanceResponseModel(
      maintenanceId: json['maintenance_id'] as String,
      requestId: json['request_id'] as String,
    );
  }
}
