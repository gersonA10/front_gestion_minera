import '../../domain/entity/attendance_finalizado_entity.dart';

class AttendanceFinalizadoModel extends AttendanceFinalizadoEntity {
  const AttendanceFinalizadoModel({
    required super.employeeId,
    required super.fullName,
    required super.shiftType,
    required super.department,
    required super.checkInTime,
    required super.checkOutTime,
    required super.totalWorkedMinutes,
    required super.hasIncident,
  });

  factory AttendanceFinalizadoModel.fromJson(Map<String, dynamic> json) {
    return AttendanceFinalizadoModel(
      employeeId: json['employee_id'] ?? '',
      fullName: json['full_name'] ?? '',
      shiftType: json['shift_type'] ?? '',
      department: json['department'] ?? '',
      checkInTime: json['check_in_time'] ?? '',
      checkOutTime: json['check_out_time'] ?? '',
      totalWorkedMinutes: json['total_worked_minutes'] ?? 0,
      hasIncident: json['has_incident'] ?? false,
    );
  }
}
