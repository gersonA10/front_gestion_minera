/// Reporte de asistencia de un trabajador en un período (semanal/mensual o rango).
class AttendanceReportEntity {
  final AttendanceReportEmployee employee;
  final AttendanceReportRange range;
  final List<AttendanceReportDay> days;
  final AttendanceReportTotals totals;

  const AttendanceReportEntity({
    required this.employee,
    required this.range,
    required this.days,
    required this.totals,
  });
}

class AttendanceReportEmployee {
  final String employeeId;
  final String fullName;
  final String position;

  const AttendanceReportEmployee({
    required this.employeeId,
    required this.fullName,
    required this.position,
  });
}

class AttendanceReportRange {
  final String from;
  final String to;

  /// 'weekly' | 'monthly' | 'custom'.
  final String period;

  const AttendanceReportRange({
    required this.from,
    required this.to,
    required this.period,
  });
}

class AttendanceReportDay {
  final String date; // YYYY-MM-DD
  final String assignedShift;
  final String? checkInTime; // HH:MM
  final String? checkOutTime; // HH:MM
  final int breakMinutes;
  final double netHoursWorked; // horas efectivas (neto de refrigerio)
  final int totalWorkedMinutes;
  final String attendanceStatus; // FINALIZADO | REVISION
  final bool hasIncident;
  final bool isOpen; // turno sin salida registrada

  const AttendanceReportDay({
    required this.date,
    required this.assignedShift,
    required this.checkInTime,
    required this.checkOutTime,
    required this.breakMinutes,
    required this.netHoursWorked,
    required this.totalWorkedMinutes,
    required this.attendanceStatus,
    required this.hasIncident,
    required this.isOpen,
  });
}

class AttendanceReportTotals {
  final int daysWorked;
  final double totalHours;
  final int totalMinutes;
  final int incidentCount;
  final int openShifts;

  const AttendanceReportTotals({
    required this.daysWorked,
    required this.totalHours,
    required this.totalMinutes,
    required this.incidentCount,
    required this.openShifts,
  });
}
