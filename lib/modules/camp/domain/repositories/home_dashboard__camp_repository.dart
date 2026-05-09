import '../entity/entity.dart';

abstract class CampRepository {
  Future<CampDashboardEntity> getDashboard({int page = 1, int limit = 10});

  Future<PaginatedTransactionHistoryEntity> getTransactionHistory({
    int page = 1,
    int limit = 10,
    String? status,
  });

  Future<CampRecentRequestEntity> createRequest(CreateCampRequestEntity request);

  Future<RequestDetailEntity> getRequestDetail(String requestId);

  Future<CloseRequestResultEntity> closeRequest(
    String requestId,
    CloseRequestEntity request,
  );
}
