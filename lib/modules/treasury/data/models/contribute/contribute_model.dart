import '../../../domain/entity/contributes/contribute_entity.dart';

class ContributeItemModel extends ContributeItemEntity {
  const ContributeItemModel({
    required super.contributionId,
    required super.reason,
    required super.period,
    required super.creationDate,
    required super.collectionGoal,
    required super.individualAmount,
    required super.totalMembers,
    required super.progressPercentage,
  });

  factory ContributeItemModel.fromJson(Map<String, dynamic> json) =>
      ContributeItemModel(
        contributionId: json['contribution_id'] as String,
        reason: json['reason'] as String,
        period: json['period'] as String,
        creationDate: json['creation_date'] as String,
        collectionGoal: (json['collection_goal'] as num).toDouble(),
        individualAmount: (json['individual_amount'] as num).toDouble(),
        totalMembers: json['total_members'] as int,
        progressPercentage: json['progress_percentage'] as int,
      );
}

class ContributeMetricsModel extends ContributeMetricsEntity {
  const ContributeMetricsModel({
    required super.totalCollected,
    required super.totalPending,
    required super.totalSocio,
  });

  factory ContributeMetricsModel.fromJson(Map<String, dynamic> json) =>
      ContributeMetricsModel(
        totalCollected: (json['total_collected'] as num).toDouble(),
        totalPending: (json['total_pending'] as num).toDouble(),
        totalSocio: json['total_socio']??'6',
      );
}
