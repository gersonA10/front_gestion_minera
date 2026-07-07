import '../../domain/entity/attendance_finalizado_entity.dart';

class AttendanceFinalizadoModel extends AttendanceFinalizadoEntity {
  const AttendanceFinalizadoModel({
    required super.attendanceId,
    required super.fullName,
    required super.shiftType,
    required super.department,
    required super.checkInTime,
    required super.checkOutTime,
    required super.totalWorkedMinutes,
    required super.hasIncident,
  });

  factory AttendanceFinalizadoModel.fromJson(Map<String, dynamic> json) {
    // El backend de la lista de finalizados NO envía `total_worked_minutes` ni
    // `has_incident`: solo manda `net_hours_worked` (horas decimales, mismo
    // valor que el detalle) y `attendance_status`. Derivamos los minutos y la
    // incidencia de ahí para que la lista coincida con el detalle.
    final netHours = (json['net_hours_worked'] as num?)?.toDouble() ?? 0;
    final status = (json['attendance_status'] ?? '').toString().toUpperCase();

    return AttendanceFinalizadoModel(
      attendanceId: json['attendance_id'] ?? '',
      fullName: json['full_name'] ?? '',
      shiftType: json['shift_type'] ?? '',
      department: json['department'] ?? '',
      checkInTime: json['check_in_time'] ?? '',
      checkOutTime: json['check_out_time'] ?? '',
      totalWorkedMinutes:
          json['total_worked_minutes'] ?? (netHours * 60).round(),
      hasIncident: json['has_incident'] ?? (status == 'REVISION'),
    );
  }
}
