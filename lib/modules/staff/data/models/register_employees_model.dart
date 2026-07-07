
import '../../domain/entity/entity.dart';

class RegisterEmployeesModel extends RegisterEmployeesEntity {
  RegisterEmployeesModel({
    required super.fullName,
    required super.nationalId,
    required super.position,
    required super.department,
    required super.baseMonthlySalary,
    required super.shiftType,
    required super.hiredDate,
    required super.seniorityLevel,
    required super.profilePhotoUrl,
  });

  factory RegisterEmployeesModel.fromEntity(RegisterEmployeesEntity entity) {
    return RegisterEmployeesModel(
      fullName: entity.fullName,
      nationalId: entity.nationalId,
      position: entity.position,
      department: entity.department,
      baseMonthlySalary: entity.baseMonthlySalary,
      shiftType: entity.shiftType,
      hiredDate: entity.hiredDate,
      seniorityLevel: entity.seniorityLevel,
      profilePhotoUrl: entity.profilePhotoUrl,
    );
  }
  Map<String,dynamic> toJson(){
    return {
      'full_name': fullName,
      'national_id': nationalId,
      'position': position,
      'department': department,
      'base_monthly_salary': baseMonthlySalary,
      'shift_type': shiftType,
      'hired_date': hiredDate,
      'seniority_level': seniorityLevel,
      'profile_photo_url': profilePhotoUrl
    };
  }
}