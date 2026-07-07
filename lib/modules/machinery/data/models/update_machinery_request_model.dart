import 'package:front_gestion_minera/modules/machinery/domain/entity/update_machinery_request_entity.dart';

class UpdateMachineryRequestModel extends UpdateMachineryRequestEntity {
  UpdateMachineryRequestModel({
    required super.machineId,
    required super.name,
    required super.typeId,
    required super.description,
    super.photoPath,
  });

  factory UpdateMachineryRequestModel.fromEntity(
    UpdateMachineryRequestEntity entity,
  ) {
    return UpdateMachineryRequestModel(
      machineId: entity.machineId,
      name: entity.name,
      typeId: entity.typeId,
      description: entity.description,
      photoPath: entity.photoPath,
    );
  }

  Map<String, dynamic> toFormDataMap() {
    return {
      'name': name,
      'type_id': typeId,
      'description': description,
    };
  }
}
