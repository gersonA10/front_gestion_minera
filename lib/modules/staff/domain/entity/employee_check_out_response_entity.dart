class EmployeeCheckOutResponseEntity {
  final String attendanceId;
  final String checkInTime;
  final String checkOutTime;
  final int breakMinutes;
  final int netHoursWorked;
  final String attendanceStatus;

  const EmployeeCheckOutResponseEntity({
    required this.attendanceId,
    required this.checkInTime,
    required this.checkOutTime,
    required this.breakMinutes,
    required this.netHoursWorked,
    required this.attendanceStatus,
  });
}