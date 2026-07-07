class EmployeeCheckOutRequestEntity {
  final String checkOutTime;
  final int breakMinutes;
  final String observations;

  const EmployeeCheckOutRequestEntity({
    required this.checkOutTime,
    required this.breakMinutes,
    required this.observations,
  });
}