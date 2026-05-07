import '../../domain/entity/entity.dart';
import '../../domain/repositories/home_dashboard__camp_repository.dart';
import '../datasource/home_dashboard__camp_datasource.dart';

class CampRepositoryImpl implements CampRepository {
  final CampDatasource datasource;

  CampRepositoryImpl({required this.datasource});

  @override
  Future<CampDashboardEntity> getDashboard({int page = 1, int limit = 10}) async {
    return await datasource.getDashboard(page: page, limit: limit);
  }

  @override
  Future<PaginatedTransactionHistoryEntity> getTransactionHistory({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final result = await datasource.getTransactionHistory(
      page: page,
      limit: limit,
      status: status,
    );
    return PaginatedTransactionHistoryEntity(
      items: (result['items'] as List).cast<TransactionHistoryEntity>(),
      hasMore: result['has_more'] as bool,
      totalRecords: result['total_records'] as int,
    );
  }

  @override
  Future<CampRecentRequestEntity> createRequest(
    CreateCampRequestEntity request,
  ) async {
    return await datasource.createRequest(request);
  }
}
