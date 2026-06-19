import '../entity/loan_detail_entity.dart';
import '../entity/loan_histori_entity.dart';
import '../entity/loan_metrics_entity.dart';

abstract class LoanHistoryRepository {
  Future<LoanHistoryPageEntity> getHistory({
    String? status,
    String? search,
    String? period,
    String? exactDate,
    int page,
    int limit,
  });

  Future<LoanMetricsEntity> getMetrics({String? period, String? exactDate});

  Future<LoanDetailEntity> getDetail(String loanId);
}
