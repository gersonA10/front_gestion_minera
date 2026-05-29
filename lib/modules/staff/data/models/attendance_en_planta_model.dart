import '../../domain/entity/attendance_en_planta_entity.dart';

class AttendanceEnPlantaModel extends AttendanceEnPlantaEntity {
  const AttendanceEnPlantaModel({
    required super.employeeId,
    required super.fullName,
    required super.department,
    required super.checkInTime,
  });

  factory AttendanceEnPlantaModel.fromJson(Map<String, dynamic> json) {
    return AttendanceEnPlantaModel(
      employeeId: json['employee_id'] ?? '',
      fullName: json['full_name'] ?? '',
      department: json['department'] ?? '',
      checkInTime: json['check_in_time'] ?? '',
    );
  }
}
