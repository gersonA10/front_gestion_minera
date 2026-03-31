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
      'items': data
          .map((item) => PendingRequestModel.fromJson(item))
          .toList(),
      'has_more_data': meta['has_more_data'] ?? false,
      'total_records': meta['total_records'] ?? 0,
    };
  }
}
