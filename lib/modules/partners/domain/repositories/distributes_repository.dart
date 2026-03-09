

import '../entity/entity.dart';

abstract class DistributesRepository {
  Future<DistributesMetricsEntity> getMetrics();
  
  Future<PaginatedDistributesHistoryEntity> getHistory({
    String? status, 
    String? search, 
    String? period, 
    String? exactDate, 
    int page = 1, 
    int limit = 10,
  });
}