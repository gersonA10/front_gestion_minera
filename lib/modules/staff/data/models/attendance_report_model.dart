import '../../domain/entity/attendance_report_entity.dart';

class AttendanceReportModel extends AttendanceReportEntity {
  const AttendanceReportModel({
    required super.employee,
    required super.range,
    required super.days,
    required super.totals,
  });

  factory AttendanceReportModel.fromJson(Map<String, dynamic> json) {
    final employee = (json['employee'] as Map<String, dynamic>?) ?? const {};
    final range = (json['range'] as Map<String, dynamic>?) ?? const {};
    final totals = (json['totals'] as Map<String, dynamic>?) ?? const {};
    final days = (json['days'] as List?) ?? const [];

    return AttendanceReportModel(
      employee: AttendanceReportEmployee(
        employeeId: employee['employee_id'] ?? '',
        fullName: employee['full_name'] ?? '',
        position: employee['position'] ?? '',
      ),
      range: AttendanceReportRange(
        from: range['from'] ?? '',
        to: range['to'] ?? '',
        period: range['period'] ?? 'weekly',
      ),
      days: days
          .map((e) => _dayFromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      totals: AttendanceReportTotals(
        daysWorked: (totals['days_worked'] as num?)?.toInt() ?? 0,
        totalHours: (totals['total_hours'] as num?)?.toDouble() ?? 0,
        totalMinutes: (totals['total_minutes'] as num?)?.toInt() ?? 0,
        incidentCount: (totals['incident_count'] as num?)?.toInt() ?? 0,
        openShifts: (totals['open_shifts'] as num?)?.toInt() ?? 0,
      ),
    );
  }

  static AttendanceReportDay _dayFromJson(Map<String, dynamic> json) {
    return AttendanceReportDay(
      date: json['date'] ?? '',
      assignedShift: json['assigned_shift'] ?? '',
      checkInTime: json['check_in_time'],
      checkOutTime: json['check_out_time'],
      breakMinutes: (json['break_minutes'] as num?)?.toInt() ?? 0,
      netHoursWorked: (json['net_hours_worked'] as num?)?.toDouble() ?? 0,
      totalWorkedMinutes: (json['total_worked_minutes'] as num?)?.toInt() ?? 0,
      attendanceStatus: json['attendance_status'] ?? '',
      hasIncident: json['has_incident'] == true,
      isOpen: json['is_open'] == true,
    );
  }
}
