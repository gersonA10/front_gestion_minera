import '../../domain/entity/personnel_cash_entity.dart';

class CashMovementModel extends CashMovementEntity {
  const CashMovementModel({
    required super.transactionId,
    required super.operationType,
    required super.amount,
    required super.description,
    required super.referenceCode,
    required super.createdAt,
  });

  factory CashMovementModel.fromJson(Map<String, dynamic> json) =>
      CashMovementModel(
        transactionId: json['transaction_id']?.toString() ?? '',
        operationType: json['operation_type'] ?? 'EXPENSE',
        amount: (json['amount'] ?? 0).toDouble(),
        description: json['description'] ?? '',
        referenceCode: json['reference_code'],
        createdAt: json['created_at'] ?? '',
      );
}

class CashPayableModel extends CashPayableEntity {
  const CashPayableModel({
    required super.payrollId,
    required super.employeeId,
    required super.fullName,
    required super.month,
    required super.year,
    required super.net,
    required super.isOverdue,
  });

  factory CashPayableModel.fromJson(Map<String, dynamic> json) =>
      CashPayableModel(
        payrollId: json['payroll_id']?.toString() ?? '',
        employeeId: json['employee_id']?.toString() ?? '',
        fullName: json['full_name'] ?? '',
        month: json['month'] ?? 0,
        year: json['year'] ?? 0,
        net: (json['net'] ?? 0).toDouble(),
        isOverdue: json['is_overdue'] ?? false,
      );
}
