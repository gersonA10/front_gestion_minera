class AttendanceFinalizadoEntity {
  final String employeeId;
  final String fullName;
  final String shiftType;
  final String department;
  final String checkInTime;
  final String checkOutTime;
  final int totalWorkedMinutes;
  final bool hasIncident;

  const AttendanceFinalizadoEntity({
    required this.employeeId,
    required this.fullName,
    required this.shiftType,
    required this.department,
    required this.checkInTime,
    required this.checkOutTime,
    required this.totalWorkedMinutes,
    required this.hasIncident,
  });
}
