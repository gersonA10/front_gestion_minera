import '../../domain/entity/entity.dart';
import '../../domain/repositories/repository.dart';
import '../datasource/datasource.dart';
import '../models/model.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminDatasource datasource;

  AdminRepositoryImpl({required this.datasource});

  @override
  Future<PaginatedPendingRequestEntity> getPendingRequests({
    int page = 1,
    int limit = 10,
  }) async {
    final result = await datasource.getPendingRequests(
      page: page,
      limit: limit,
    );

    final models = result['items'] as List<PendingRequestModel>;

    return PaginatedPendingRequestEntity(
      items: models.map((model) => model.toEntity()).toList(),
      hasMoreData: result['has_more_data'] as bool,
      totalRecords: result['total_records'] as int? ?? 0,
    );
  }

  @override
  Future<PaginatedRequestHistoryEntity> getRequestHistory({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final result = await datasource.getRequestHistory(
      page: page,
      limit: limit,
      status: status,
    );
    final models = result['items'] as List<RequestHistoryModelAdmin>;
    return PaginatedRequestHistoryEntity(
      items: models.map((model) => model.toEntity()).toList(),
      hasMoreData: result['has_more_data'] as bool,
      totalRecords: result['total_records'] as int? ?? 0,
    );
  }

  @override
  Future<PaginatedContributionHistoryEntity> getContributesHistory({
    int page = 1,
    int limit = 10,
    String? exactDate,
    String? period,
  }) async {
    final result = await datasource.getContributesHistory(
      page: page,
      limit: limit,
      exactDate: exactDate,
      period: period
    );
    final models = result['items'] as List<ContributionHistoryModel>;
    return PaginatedContributionHistoryEntity(
      items: models.map((model) => model.toEntity()).toList(),
      hasMoreData: result['has_more_data'] as bool,
      totalRecords: result['total_records'] as int? ?? 0,
    );
  }
}
