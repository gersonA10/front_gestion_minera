import '../entity/entity.dart';

abstract class PartnersRepository {
  Future<ContributionMetricsEntity> getContributionMetrics();
  
  Future<List<ContributeHistoryDataEntity>> getContributeHistory({
    String? period,
    String? exactDate,
    String? status,
    String? search,
  });
}