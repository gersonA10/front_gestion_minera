class EmployeeCheckOutRequestModel {
  final String checkOutTime;
  final int breakMinutes;
  final String observations;

  const EmployeeCheckOutRequestModel({
    required this.checkOutTime,
    required this.breakMinutes,
    required this.observations,
  });

  Map<String, dynamic> toJson() {
    return {
      'check_out_time': checkOutTime,
      'break_minutes': breakMinutes,
      'observations': observations,
    };
  }
}