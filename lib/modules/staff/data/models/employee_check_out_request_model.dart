import '../../domain/entity/entity.dart';

class EmployeeCheckOutRequestModel {
  final String checkOutTime;
  final int breakMinutes;
  final String observations;

  const EmployeeCheckOutRequestModel({
    required this.checkOutTime,
    required this.breakMinutes,
    required this.observations,
  });

  factory EmployeeCheckOutRequestModel.fromEntity(
    EmployeeCheckOutRequestEntity entity,
  ) {
    return EmployeeCheckOutRequestModel(
      checkOutTime: entity.checkOutTime,
      breakMinutes: entity.breakMinutes,
      observations: entity.observations,
    );
  }

  Map<String,dynamic> toJson(){
    return{
      'check_out_time':checkOutTime,
      'break_minutes':breakMinutes,
      'observations':observations,
    };
  }
}