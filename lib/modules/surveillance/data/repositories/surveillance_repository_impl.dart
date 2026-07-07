import '../../domain/entity/entity.dart';
import '../../domain/repositories/repository.dart';
import '../datasource/datasource.dart';
import '../models/model.dart';
import '../models/surveillance_models.dart';

class SurveillanceRepositoryImpl implements SurveillanceRepository {
  final SurveillanceDatasource datasource;

  SurveillanceRepositoryImpl({required this.datasource});

  @override
  Future<PaginatedSurveillanceHistoryEntity> getHistory({
    String? status,
    String? search,
    String? period,
    String? exactDate,
    int page = 1,
    int limit = 10,
  }) async {
    final result = await datasource.getHistory(
      status: status,
      search: search,
      period: period,
      exactDate: exactDate,
      page: page,
      limit: limit,
    );

    final models = result['items'] as List<SurveillanceHistoryModel>;

    return PaginatedSurveillanceHistoryEntity(
      items: models.map((model) => model.toEntity()).toList(),
      hasMoreData: result['has_more_data'] as bool,
      totalRecords: result['total_records'] as int? ?? 0,
    );
  }

  @override
  Future<MonitoringTrayEntity> monitoringTray({
    int page = 1,
    int limit = 10,
  }) async {
    final result = await datasource.monitoringTray(page: page, limit: limit);
    final models = result['items'] as List<MonitoringTrayDataModel>;
    return MonitoringTrayEntity(
      items: models.map((model) => model.toEntity()).toList(),
      hasMoreData: result['has_more_data'] as bool,
      totalRecords: result['total_records'] as int? ?? 0,
    );
  }

  @override
  Future<ContributionCalculationEntity> calculateContribution(
    double montoTotal,
  ) async {
    final data = await datasource.calculateContribution(montoTotal);
    return ContributionCalculationModel.fromJson(data);
  }

  @override
  Future<ContributionRegistrationEntity> registerContribution(
    double montoTotal,
    String motivo,
  ) async {
    final data = await datasource.registerContribution(montoTotal, motivo);
    return ContributionRegistrationModel.fromJson(data);
  }

  @override
  Future<ApproveTheRequestEntity> approveTheRequest(
    String requestId,
    String action,
    String reason,
  ) async {
    return await datasource.approveTheRequest(requestId, action, reason);
  }
}
