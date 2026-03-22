
import '../../../../core/networking/http_services.dart';
import '../../domain/entity/entity.dart';
import '../models/model.dart';

class TreasuryDatasource {
  final ApiClient apiClient;

  TreasuryDatasource({required this.apiClient});

  Future<TreasuryMetricsModel> getMetrics() async {
    final response = await apiClient.get(
      '/api/treasury/dashboard/home',
      operationName: 'getTreasuryMetrics',
    );
    return TreasuryMetricsModel.fromJson(response['data']);
  }

  Future<BondBalanceResponseModel> getBondBalence() async {
    final response = await apiClient.get(
      '/api/treasury/finance/balances',
      operationName: 'getBondBalence',
    );
    return BondBalanceResponseModel.fromJson(response['data']);
  }

  Future<PendingApplicationsResponseEntity> getPendingApplications() async {
    final response = await apiClient.get(
      '/api/treasury/requests/recent',
      operationName: 'getPendingApplications',
    );
    return PendingApplicationsResponseModel.fromJson(response);
  }

  Future<DetailsofanapplicationResponseEntity> getDetailsofanapplication(
    String id,
  ) async {
    final response = await apiClient.get(
      '/api/treasury/requests/$id',
      operationName: 'getDetailsofanapplication',
    );
    return DetailsofanapplicationResponseModel.fromJson(response);
  }
  
  Future<CashResponseEntity> getCash(
  ) async {
    final response = await apiClient.get(
      'api/treasury/cash-registers',
      operationName: 'getCash',
    );
    return CashResponseModel.fromJson(response);
  }


  Future<Map<String, dynamic>> listOfPendingRequests({
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, dynamic> queryParameters = {'page': page, 'limit': limit};

    final response = await apiClient.get(
      '/api/treasury/requests/pending',
      operationName: 'listOfPendingRequests',
      queryParameters: queryParameters,
    );
    final List<dynamic> data = response['data'] ?? [];
    final Map<String, dynamic> meta = response['meta'] ?? {};
    return {
      'items': data
          .map((item) => ListOfPendingRequestsResponseModel.fromJson(item))
          .toList(),
      'has_more_data': meta['has_more_data'] ?? false,

      'total_records': meta['total_records'] ?? 0,
    };
  }
}
