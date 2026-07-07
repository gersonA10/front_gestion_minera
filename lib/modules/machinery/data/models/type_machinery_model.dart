import '../../domain/entity/entity.dart';

class TypeMachineryModel extends TypeMachineryEntity {
  TypeMachineryModel({
    required super.id,
    required super.code,
    required super.name,
    required super.prefix,
  });
  factory TypeMachineryModel.fromJson(Map<String, dynamic> json) {
    return TypeMachineryModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      prefix: json['prefix'],
    );
  }
}
