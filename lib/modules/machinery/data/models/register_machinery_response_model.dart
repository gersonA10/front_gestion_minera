import 'package:front_gestion_minera/modules/machinery/domain/entity/register_machinery_response_entity.dart';

class RegisterMachineryResponseModel extends RegisterMachineryResponseEntity {
  RegisterMachineryResponseModel({
    required super.machineId,
    required super.uniqueCode,
  });

  factory RegisterMachineryResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterMachineryResponseModel(
      machineId: json['machine_id'],
      uniqueCode: json['unique_code'],
    );
  }
}
