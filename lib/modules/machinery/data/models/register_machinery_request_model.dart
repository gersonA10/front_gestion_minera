import 'package:front_gestion_minera/modules/machinery/domain/entity/register_machinery_request_entity.dart';

class RegisterMachineryRequestModel extends RegisterMachineryRequestEntity {
  RegisterMachineryRequestModel({
    required super.name,
    required super.uniqueCode,
    required super.typeId,
    required super.description,
    required super.photoPath,
  });

  factory RegisterMachineryRequestModel.fromEntity(
    RegisterMachineryRequestEntity entity,
  ) {
    return RegisterMachineryRequestModel(
      name: entity.name,
      uniqueCode: entity.uniqueCode,
      typeId: entity.typeId,
      description: entity.description,
      photoPath: entity.photoPath,
    );
  }

  Map<String, dynamic> toFormDataMap() {
    return {
      'name': name,
      'unique_code': uniqueCode,
      'type_id': typeId,
      'description': description,
    };
  }
}
