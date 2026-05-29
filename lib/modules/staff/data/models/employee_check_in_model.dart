import 'package:front_gestion_minera/modules/staff/domain/entity/entity.dart';

class EmployeeCheckInModel extends EmployeeCheckInEntity {
  EmployeeCheckInModel({
    required super.employeeId,
    required super.assignedShift,
    required super.checkInTime,
    required super.eppData,
    required super.observation,
  });

  factory EmployeeCheckInModel.fromEntity(EmployeeCheckInEntity entity) {
    return EmployeeCheckInModel(
      employeeId: entity.employeeId,
      assignedShift: entity.assignedShift,
      checkInTime: entity.checkInTime,
      eppData: entity.eppData,
      observation: entity.observation,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "employee_id": employeeId,
      "assigned_shift": assignedShift,
      "check_in_time": checkInTime,
      "epp_data": eppData,
      "observations":observation,
    };
  }
}
