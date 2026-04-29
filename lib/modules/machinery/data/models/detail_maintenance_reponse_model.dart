import '../../domain/entity/entity.dart';
import 'model.dart';

class DetailMaintenanceResponseModel extends DetailMaintenanceResponseEntity {

  DetailMaintenanceResponseModel({
    required super.maintenanceId,
    required super.failureType,
    required super.description,
    required super.estimatedAmount,
    required super.evidenceUrl,
    required super.requestedAt,
    required super.machine,
    required super.request,
  });

  factory DetailMaintenanceResponseModel.fromJson(Map<String, dynamic> json) {
    return DetailMaintenanceResponseModel(
      maintenanceId: json["maintenance_id"],
      failureType: json["failure_type"],
      description: json["description"],
      estimatedAmount: json["estimated_amount"],
      evidenceUrl: json["evidence_url"] ?? "",
      requestedAt: DateTime.parse(json["requested_at"]),
      machine: MachineDataModel.fromJson(json["machine"]),
      request: RequestDataModel.fromJson(json["request"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "maintenance_id": maintenanceId,
      "failure_type": failureType,
      "description": description,
      "estimated_amount": estimatedAmount,
      "evidence_url": evidenceUrl,
      "requested_at": requestedAt.toIso8601String(),
      "machine": (machine as MachineDataModel).toJson(),
      "request": (request as RequestDataModel).toJson(),
    };
  }
}