import 'package:front_gestion_minera/core/networking/http_services.dart';

import '../models/model.dart';

class AdminDatasource {
  final ApiClient apiClient;

  AdminDatasource({required this.apiClient});

  Future<Map<String, dynamic>> getPendingRequests({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await apiClient.get(
      '/api/admin/requests/pending',
      operationName: 'getPendingRequests',
      queryParameters: {'page': page, 'limit': limit},
    );

    final List<dynamic> data = response['data'] ?? [];
    final Map<String, dynamic> meta = response['meta'] ?? {};

    return {
      'items': data.map((item) => PendingRequestModel.fromJson(item)).toList(),
      'has_more_data': meta['has_more_data'] ?? false,
      'total_records': meta['total_records'] ?? 0,
    };
  }

  Future<Map<String, dynamic>> getRequestHistory({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null && status != 'todos') {
      queryParams['status'] = status;
    }

    final response = await apiClient.get(
      '/api/admin/requests/history',
      operationName: 'getRequestHistory',
      queryParameters: queryParams,
    );

    final List<dynamic> data = response['data'] ?? [];
    final Map<String, dynamic> meta = response['meta'] ?? {};

    return {
      'items': data
          .map((item) => RequestHistoryModelAdmin.fromJson(item))
          .toList(),
      'has_more_data': meta['has_more_data'] ?? false,
      'total_records': meta['total_records'] ?? 0,
    };
  }

Future<Map<String, dynamic>> getContributesHistory({
    int page = 1,
    int limit = 10,
    String? period,     
    String? exactDate,  
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (exactDate != null && exactDate.isNotEmpty && period != null) {
      final parts = exactDate.split('-'); 
      final year = parts[0];

      if (period == 'day') {
        queryParams['exact_date'] = exactDate; 
      } 
      else if (period == 'month') {
        queryParams['month'] = parts[1]; 
        queryParams['year'] = year;
      } 
      else if (period == 'year') {
        queryParams['year'] = year;
      }
    }

    final response = await apiClient.get(
      '/api/admin/contributions/history',
      operationName: 'getContributionHistory',
      queryParameters: queryParams,
    );

    final List<dynamic> data = response['data'] ?? [];
    final Map<String, dynamic> meta = response['meta'] ?? {};

    return {
      'items': data.map((item) => ContributionHistoryModel.fromJson(item)).toList(),
      'has_more_data': meta['has_more_data'] ?? false,
      'total_records': meta['total_records'] ?? 0,
    };
  }
}
