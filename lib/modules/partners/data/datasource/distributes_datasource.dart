import 'package:front_gestion_minera/core/networking/http_services.dart';
import '../models/distributes_model.dart';

class DistributesDatasource {
  final ApiClient apiClient;

  DistributesDatasource({required this.apiClient});

  Future<DistributesMetricsModel> getMetrics() async {
    final response = await apiClient.get(
      '/api/distributions/metrics',
      operationName: 'getDistributionsMetrics',
    );
    return DistributesMetricsModel.fromJson(response['data'] ?? {});
  }

  Future<Map<String, dynamic>> getHistory({
    String? status,
    String? search,
    String? period,
    String? exactDate,
    int page = 1,
    int limit = 20,
  }) async {
    final Map<String, dynamic> queryParameters = {'page': page, 'limit': limit};

    if (status != null && status.toLowerCase() != 'todo') {
      queryParameters['status'] = status.toLowerCase();
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }
    if (period != null) queryParameters['period'] = period;
    if (exactDate != null) queryParameters['exact_date'] = exactDate;

    final response = await apiClient.get(
      '/api/distributions/history',
      operationName: 'getDistributionsHistory',
      queryParameters: queryParameters,
    );

    final List<dynamic> data = response['data'] ?? [];
    final Map<String, dynamic> meta = response['meta'] ?? {};

    return {
      'items': data.map((item) => DistributesHistoryModel.fromJson(item)).toList(),
      'has_more_data': meta['has_more_data'] ?? false,
    };
  }
}