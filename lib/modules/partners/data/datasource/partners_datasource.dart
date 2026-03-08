import '../../../../core/networking/http_services.dart';
import '../../domain/entity/entity.dart';
import '../models/model.dart';

class PartnersDatasource {
  final ApiClient apiClient;
  PartnersDatasource({required this.apiClient});

  Future<ContributionMetricsModel> getContributionMetrics() async {
    final response = await apiClient.get(
      '/api/contributions/metrics',
      operationName: 'getContributionMetrics',
    );
    return ContributionMetricsModel.fromJson(response['data'] ?? {});
  }

  Future<List<ContributeHistoryDataEntity>> getContributeHistory({
    String? period,
    String? exactDate,
    String? status,
    String? search,
  }) async {
    final Map<String, dynamic> queryParameters = {};

    if (period != null) queryParameters['period'] = period;
    if (exactDate != null) queryParameters['exact_date'] = exactDate;
    if (status != null && status.toLowerCase() != 'todo') {
       queryParameters['status'] = status.toLowerCase();
    }
    if (search != null && search.trim().isNotEmpty) {
       queryParameters['search'] = search.trim();
    }

    final response = await apiClient.get(
      '/api/contributions/history',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      operationName: 'getContributeHistory',
    );

    return ContributeHistoryResponseModel.fromJson(response).data;
  }
}