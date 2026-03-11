import 'package:front_gestion_minera/core/networking/http_services.dart';
import 'package:front_gestion_minera/modules/surveillance/data/models/surveillance_models.dart';

import '../models/model.dart';

class SurveillanceDatasource {
  final ApiClient apiClient;

  SurveillanceDatasource({required this.apiClient});

  Future<Map<String, dynamic>> getHistory({
    String? status,
    String? search,
    String? period,
    String? exactDate,
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, dynamic> queryParameters = {'page': page, 'limit': limit};

    if (status != null && status.toLowerCase() != 'todos') {
      queryParameters['status'] = status.toLowerCase();
    }
    if (period != null) queryParameters['period'] = period;
    if (exactDate != null) queryParameters['exact_date'] = exactDate;

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    final response = await apiClient.get(
      '/api/viewHistory/history',
      operationName: 'getSurveillanceHistory',
      queryParameters: queryParameters,
    );

    final List<dynamic> data = response['data'] ?? [];
    final Map<String, dynamic> meta = response['meta'] ?? {};

    return {
      'items': data
          .map((item) => SurveillanceHistoryModel.fromJson(item))
          .toList(),
      'has_more_data': meta['has_more_data'] ?? false,
      'total_records': meta['total_records'] ?? 0,
    };
  }

  Future<Map<String, dynamic>> monitoringTray({
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, dynamic> queryParameters = {'page': page, 'limit': limit};

    final response = await apiClient.get(
      '/api/viewRequests/history',
      operationName: 'I will process the application tray data.',
      queryParameters: queryParameters,
    );
    final List<dynamic> data = response['data'] ?? [];
    final Map<String, dynamic> meta = response['meta'] ?? {};
    return {
      'items': data
          .map((item) => MonitoringTrayDataModel.fromJson(item))
          .toList(),
      'has_more_data': meta['has_more_data'] ?? false,
      'total_records': meta['total_records'] ?? 0,
    };
  }

  Future<Map<String, dynamic>> calculateContribution(double montoTotal) async {
    final response = await apiClient.get(
      '/api/surveillance/contributions/calculate',
      queryParameters: {'monto_total': montoTotal.toString()},
      operationName: 'calculateContribution',
    );
    return response['data'];
  }

  Future<Map<String, dynamic>> registerContribution(
    double montoTotal,
    String motivo,
  ) async {
    final Map<String, dynamic> body = {'monto_total': montoTotal};
    if (motivo.trim().isNotEmpty) {
      body['motivo'] = motivo.trim();
    }

    final response = await apiClient.post(
      '/api/surveillance/contributions/register',
      data: body,
      operationName: 'registerContribution',
    );
    return response['data'];
  }
}
