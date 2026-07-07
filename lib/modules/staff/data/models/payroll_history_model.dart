import '../../domain/entity/payroll_history_entity.dart';

class PayrollHistoryModel extends PayrollHistoryEntity {
  const PayrollHistoryModel({
    required super.period,
    required super.payrollType,
    required super.totalAmount,
    required super.paymentDate,
    required super.status,
  });

  factory PayrollHistoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PayrollHistoryModel(
      period: json['period'] ?? '',
      payrollType: json['payroll_type'] ?? '',
      totalAmount:
          (json['total_amount'] as num?)?.toDouble() ?? 0,
      paymentDate: json['payment_date'] ?? '',
      status: json['status'] ?? '',
    );
  }
}