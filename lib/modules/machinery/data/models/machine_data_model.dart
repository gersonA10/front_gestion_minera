import '../../domain/entity/entity.dart';

class MachineDataModel extends MachineData {

  MachineDataModel({
    required super.machineId,
    required super.name,
    required super.uniqueCode,
    required super.type,
    required super.status,
    required super.photoUrl,
  });

  factory MachineDataModel.fromJson(Map<String, dynamic> json) {
    return MachineDataModel(
      machineId: json["machine_id"],
      name: json["name"],
      uniqueCode: json["unique_code"],
      type: json["type"],
      status: json["status"],
      photoUrl: json["photo_url"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "machine_id": machineId,
      "name": name,
      "unique_code": uniqueCode,
      "type": type,
      "status": status,
      "photo_url": photoUrl,
    };
  }
}