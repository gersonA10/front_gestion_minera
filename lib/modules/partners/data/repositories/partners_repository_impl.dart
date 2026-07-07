import '../../domain/entity/entity.dart';
import '../../domain/repositories/repository.dart';
import '../datasource/datasource.dart';

class PartnersRepositoryImpl extends PartnersRepository {
  final PartnersDatasource datasource;
  PartnersRepositoryImpl({required this.datasource});

  @override
  Future<ContributionMetricsEntity> getContributionMetrics() async {
    return await datasource.getContributionMetrics();
  }

  @override
  Future<List<ContributeHistoryDataEntity>> getContributeHistory({
    String? period,
    String? exactDate,
    String? status,
    String? search,
  }) async {
    return await datasource.getContributeHistory(
      period: period,
      exactDate: exactDate,
      status: status,
      search: search,
    );
  }
}