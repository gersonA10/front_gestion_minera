import '../../domain/entity/employee_entity.dart';

class EmployeeModel extends EmployeeEntity {
  const EmployeeModel({
    required super.employeeId,
    required super.fullName,
    required super.nationalId,
    required super.position,
    required super.department,
    required super.status,
    required super.profilePhotoUrl,
    required super.shiftType,
    required super.monthsSeniority,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      employeeId: json['employee_id'] ?? '',
      fullName: json['full_name'] ?? '',
      nationalId: json['national_id'] ?? '',
      position: json['position'] ?? '',
      department: json['department'] ?? '',
      status: json['status'] ?? '',
      profilePhotoUrl: json['profile_photo_url'] ?? '',
      shiftType: json['shift_type'] ?? '',
      monthsSeniority: json['months_seniority'] ?? 0,
    );
  }
}