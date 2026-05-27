class EmployeeEntity {
  final String employeeId;
  final String fullName;
  final String nationalId;
  final String position;
  final String department;
  final double baseMonthlySalary;
  final String status;
  final String profilePhotoUrl;
  final String shiftType;
  final String seniorityLevel;
  final String hiredDate;
  final int monthsSeniority;

  const EmployeeEntity({
    required this.employeeId,
    required this.fullName,
    required this.nationalId,
    required this.position,
    required this.department,
    required this.baseMonthlySalary,
    required this.status,
    required this.profilePhotoUrl,
    required this.shiftType,
    required this.seniorityLevel,
    required this.hiredDate,
    required this.monthsSeniority,
  });
}
