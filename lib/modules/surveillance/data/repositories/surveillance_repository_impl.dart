
import '../../domain/entity/entity.dart';
import '../../domain/repositories/repository.dart';
import '../datasource/datasource.dart';
import '../models/model.dart';

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
    );
  }
}