class AttendanceIngresoEntity {
  final String employeeId;
  final String fullName;
  final String position;
  final String assignedShiftScheduled;
  final String scheduledTime;

  const AttendanceIngresoEntity({
    required this.employeeId,
    required this.fullName,
    required this.position,
    required this.assignedShiftScheduled,
    required this.scheduledTime,
  });
}
