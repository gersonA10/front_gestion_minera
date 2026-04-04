import '../entity/entity.dart';

abstract class AdminRepository {
  Future<PaginatedPendingRequestEntity> getPendingRequests({
    int page = 1,
    int limit = 10,
  });

  Future<PaginatedRequestHistoryEntity> getRequestHistory({
    int page = 1,
    int limit = 10,
    String? status,
  });

  Future<PaginatedContributionHistoryEntity> getContributesHistory({
    int page = 1,
    int limit = 10,
    String? exactDate,
    String? period,
  });

  Future<RequestDetailEntity> getRequestDetail(String id);
}
