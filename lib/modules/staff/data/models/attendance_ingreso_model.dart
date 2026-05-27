import '../../domain/entity/attendance_ingreso_entity.dart';

class AttendanceIngresoModel extends AttendanceIngresoEntity {
  const AttendanceIngresoModel({
    required super.employeeId,
    required super.fullName,
    required super.position,
    required super.assignedShiftScheduled,
    required super.scheduledTime,
  });

  factory AttendanceIngresoModel.fromJson(Map<String, dynamic> json) {
    return AttendanceIngresoModel(
      employeeId: json['employee_id'] ?? '',
      fullName: json['full_name'] ?? '',
      position: json['position'] ?? '',
      assignedShiftScheduled: json['assigned_shift_scheduled'] ?? '',
      scheduledTime: json['scheduled_time'] ?? '',
    );
  }
}
