import '../entity/entity.dart';

abstract class SurveillanceRepository {
  Future<PaginatedSurveillanceHistoryEntity> getHistory({
    String? status,
    String? search,
    String? period,
    String? exactDate,
    int page = 1,
    int limit = 10,
  });
  Future<MonitoringTrayEntity> monitoringTray({int page = 1, int limit = 10});
  Future<ContributionCalculationEntity> calculateContribution(
    double montoTotal,
  );
  Future<ContributionRegistrationEntity> registerContribution(
    double montoTotal, String motivo);
}
