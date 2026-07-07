import '../../domain/entity/employee_balance_entity.dart';

class EmployeeBalanceModel extends EmployeeBalanceEntity {
  const EmployeeBalanceModel({
    required super.totalPendingAmount,
    required super.totalPendingMonths,
    required super.overdueAmount,
    required super.overdueMonths,
  });

  factory EmployeeBalanceModel.fromJson(Map<String, dynamic> json) =>
      EmployeeBalanceModel(
        totalPendingAmount: (json['total_pending_amount'] ?? 0).toDouble(),
        totalPendingMonths: json['total_pending_months'] ?? 0,
        overdueAmount: (json['overdue_amount'] ?? 0).toDouble(),
        overdueMonths: json['overdue_months'] ?? 0,
      );
}
