class EmployeeCheckInEntity {
  final String employeeId;
  final String assignedShift;
  final String checkInTime;
  final Map<String, bool> eppData;
  final String observation;

  EmployeeCheckInEntity({
    required this.employeeId,
    required this.assignedShift,
    required this.checkInTime,
    required this.eppData,
    required this.observation,
  });
}
