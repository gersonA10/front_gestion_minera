import '../../domain/entity/loan_detail_entity.dart';
import '../../domain/entity/loan_histori_entity.dart';
import '../../domain/entity/loan_metrics_entity.dart';
import '../../domain/repositories/repository.dart';
import '../datasource/datasource.dart';

class LoanHistoryRepositoryImpl extends LoanHistoryRepository {
  final LoanHistoryDatasource datasource;
  LoanHistoryRepositoryImpl({required this.datasource});

  @override
  Future<LoanHistoryPageEntity> getHistory({
    String? status,
    String? search,
    String? period,
    String? exactDate,
    int page = 1,
    int limit = 10,
  }) {
    return datasource.getHistory(
      status: status,
      search: search,
      period: period,
      exactDate: exactDate,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<LoanMetricsEntity> getMetrics({String? period, String? exactDate}) {
    return datasource.getMetrics(period: period, exactDate: exactDate);
  }

  @override
  Future<LoanDetailEntity> getDetail(String loanId) {
    return datasource.getDetail(loanId);
  }
}
