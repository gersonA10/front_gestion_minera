class RegisterEmployeesEntity {
  final String fullName;
  final String nationalId;
  final String position;
  final String department;
  final double baseMonthlySalary;
  final String shiftType;
  final String hiredDate;
  final String seniorityLevel;
  final String? profilePhotoUrl;

  RegisterEmployeesEntity({
    required this.fullName,
    required this.nationalId,
    required this.position,
    required this.department,
    required this.baseMonthlySalary,
    required this.shiftType,
    required this.hiredDate,
    required this.seniorityLevel,
    required this.profilePhotoUrl,
  });
}
