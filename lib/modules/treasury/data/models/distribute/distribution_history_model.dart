import '../../../domain/entity/distribute/distribution_history_entity.dart';

class DistributionHistoryItemModel extends DistributionHistoryItemEntity {
  const DistributionHistoryItemModel({
    required super.distributionId,
    required super.period,
    required super.registeredDate,
    required super.status,
    required super.registeredAmount,
    required super.amountPaid,
    required super.amountDue,
    required super.progressPct,
  });

  factory DistributionHistoryItemModel.fromJson(Map<String, dynamic> json) =>
      DistributionHistoryItemModel(
        distributionId: json['distribution_id'] as String,
        period: json['period'] as String,
        registeredDate: json['registered_date'] as String,
        status: json['status'] as String,
        registeredAmount: (json['registered_amount'] as num).toDouble(),
        amountPaid: (json['amount_paid'] as num).toDouble(),
        amountDue: (json['amount_due'] as num).toDouble(),
        progressPct: json['progress_pct'] as int,
      );
}
