import 'package:front_gestion_minera/modules/machinery/domain/entity/failure_type_entity.dart';

class FailureTypeModel extends FailureTypeEntity {
  FailureTypeModel({required super.value, required super.label});

  factory FailureTypeModel.fromJson(Map<String, dynamic> json) {
    return FailureTypeModel(
      value: json['value'] as String,
      label: json['label'] as String,
    );
  }
}
