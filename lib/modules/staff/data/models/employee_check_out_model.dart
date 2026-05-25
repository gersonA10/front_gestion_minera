

import 'package:front_gestion_minera/modules/staff/domain/entity/employee_check_out_entity.dart';

class EmployeeCheckOutModel extends EmployeeCheckOutEntity {
  const EmployeeCheckOutModel({
    required super.attendanceId,
    required super.checkInTime,
    required super.checkOutTime,
    required super.breakMinutes,
    required super.netHoursWorked,
    required super.attendanceStatus,
  });

  factory EmployeeCheckOutModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EmployeeCheckOutModel(
      attendanceId: json['attendance_id'] ?? '',
      checkInTime: json['check_in_time'] ?? '',
      checkOutTime: json['check_out_time'] ?? '',
      breakMinutes: json['break_minutes'] ?? 0,
      netHoursWorked: json['net_hours_worked'] ?? 0,
      attendanceStatus: json['attendance_status'] ?? '',
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