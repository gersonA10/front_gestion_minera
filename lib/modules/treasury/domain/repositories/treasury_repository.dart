import '../entity/entity.dart';

abstract class TreasuryRepository {
  Future<TreasuryMetricsEntity> getMetrics();
  Future<BondBalanceResponseEntity> getBondBalence();
  Future<PendingApplicationsResponseEntity> getPendingApplications();
  Future<DetailsofanapplicationResponseEntity> getDetailsofanapplication(
    String id,
  );
  Future<CashResponseEntity> getCash();

}
