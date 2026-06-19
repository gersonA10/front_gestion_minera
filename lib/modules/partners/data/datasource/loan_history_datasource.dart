import 'package:front_gestion_minera/core/networking/http_services.dart';
import '../../domain/entity/loan_detail_entity.dart';
import '../../domain/entity/loan_histori_entity.dart';
import '../../domain/entity/loan_metrics_entity.dart';
import '../models/loan_detail_model.dart';
import '../models/loan_history_model.dart';
import '../models/loan_metrics_model.dart';

class LoanHistoryDatasource {
  final ApiClient apiClient;
  LoanHistoryDatasource({required this.apiClient});

  /// GET /api/loans/history (paginado + filtros).
  Future<LoanHistoryPageEntity> getHistory({
    String? status,
    String? search,
    String? period,
    String? exactDate,
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, dynamic> queryParameters = {'page': page, 'limit': limit};

    if (status != null && status.trim().isNotEmpty) {
      queryParameters['status'] = status;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }
    if (period != null) queryParameters['period'] = period;
    if (exactDate != null) queryParameters['exact_date'] = exactDate;

    final response = await apiClient.get(
      '/api/loans/history',
      operationName: 'getLoanHistory',
      queryParameters: queryParameters,
    );

    return LoanHistoryDataModel.pageFromResponse(
      response as Map<String, dynamic>,
    );
  }

  /// GET /api/loans/metrics.
  Future<LoanMetricsEntity> getMetrics({
    String? period,
    String? exactDate,
  }) async {
    final Map<String, dynamic> queryParameters = {};
    if (period != null) queryParameters['period'] = period;
    if (exactDate != null) queryParameters['exact_date'] = exactDate;

    final response = await apiClient.get(
      '/api/loans/metrics',
      operationName: 'getLoanMetrics',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    return LoanMetricsModel.fromJson(response['data'] ?? {});
  }

  /// GET /api/loans/:loan_id (detalle: cronograma + pagos).
  Future<LoanDetailEntity> getDetail(String loanId) async {
    final response = await apiClient.get(
      '/api/loans/$loanId',
      operationName: 'getLoanDetail',
    );

    return LoanDetailModel.fromJson(response['data'] ?? {});
  }
}
