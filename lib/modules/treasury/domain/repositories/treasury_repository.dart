import '../entity/treasury_metrics_entity.dart';

abstract class TreasuryRepository {
  Future<TreasuryMetricsEntity> getMetrics();
}