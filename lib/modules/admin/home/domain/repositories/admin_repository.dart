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

  Future<ProcessRequestResponseEntity> processRequest({
    required String id,
    required String action,
    String? reason,
  });

  Future<CreateContributionResponseEntity> createContribution({
    required String motivo,
    required String periodMonth,
    required String periodYear,
    required double monto,
    required String tipoCalculo,
  });

  Future<ContributionSimulationEntity> simulateContribution({
    required double monto,
    required String tipoCalculo,
  });
}
