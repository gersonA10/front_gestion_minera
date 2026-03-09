import '../../domain/entity/entity.dart';
import '../../domain/repositories/distributes_repository.dart';
import '../datasource/distributes_datasource.dart';
import '../models/distributes_model.dart';

class DistributesRepositoryImpl implements DistributesRepository {
  final DistributesDatasource datasource;

  DistributesRepositoryImpl({required this.datasource});

  @override
  Future<DistributesMetricsEntity> getMetrics() async {
    return await datasource.getMetrics();
  }

  @override
  Future<PaginatedDistributesHistoryEntity> getHistory({
    String? status, String? search, String? period, String? exactDate, int page = 1, int limit = 20,
  }) async {
    final result = await datasource.getHistory(
      status: status, search: search, period: period, exactDate: exactDate, page: page, limit: limit
    );
    
    final models = result['items'] as List<DistributesHistoryModel>;
    return PaginatedDistributesHistoryEntity(
      items: models.map((model) => model.toEntity()).toList(),
      hasMoreData: result['has_more_data'] as bool,
    );
  }
}