
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
}