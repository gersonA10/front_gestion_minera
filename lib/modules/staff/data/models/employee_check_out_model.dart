import 'package:front_gestion_minera/modules/staff/domain/entity/employee_check_out_response_entity.dart';

class EmployeeCheckOutModel extends EmployeeCheckOutResponseEntity {
  const EmployeeCheckOutModel({
    required super.attendanceId,
    required super.checkInTime,
    required super.checkOutTime,
    required super.breakMinutes,
    required super.netHoursWorked,
    required super.attendanceStatus,
  });

  factory EmployeeCheckOutModel.fromJson(Map<String, dynamic> json) {
    return EmployeeCheckOutModel(
      attendanceId: json['attendance_id']?.toString() ?? '',
      checkInTime: json['check_in_time']?.toString() ?? '',
      checkOutTime: json['check_out_time']?.toString() ?? '',
      breakMinutes: (json['break_minutes'] as num?)?.toInt() ?? 0,
      netHoursWorked: (json['net_hours_worked'] as num?)?.toInt() ?? 0,
      attendanceStatus: json['attendance_status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_id': attendanceId,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'break_minutes': breakMinutes,
      'net_hours_worked': netHoursWorked,
      'attendance_status': attendanceStatus,
    };
  }
}
