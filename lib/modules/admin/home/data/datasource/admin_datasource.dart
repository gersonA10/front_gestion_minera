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

    bool toBool(dynamic v) => v == true || v == 'true' || v == 1 || v == '1';
    int toInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

    return {
      'items': data
          .whereType<Map>()
          .map(
            (item) => RequestHistoryModelAdmin.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      'has_more_data': toBool(meta['has_more_data']),
      'total_records': toInt(meta['total_records']),
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

  Future<RequestDetailModel> getRequestDetail(String id) async {
    final response = await apiClient.get(
      '/api/admin/requests/$id',
      operationName: 'getRequestDetail',
    );
    return RequestDetailModel.fromJson(response['data']);
  }

Future<ProcessRequestResponseModel> processRequest({
    required String id,
    required String action,
    String? reason,
  }) async {
    final body = <String, dynamic>{'action': action};
    
    if (action == 'rechazado' && reason != null && reason.isNotEmpty) {
      body['reason'] = reason;
    }

    final response = await apiClient.post(
      '/api/admin/requests/$id/process',
      operationName: 'processAdminRequest',
      data: body,
    );

    return ProcessRequestResponseModel.fromJson(response);
  }

  Future<CreateContributionResponseModel> createContribution({
    required String motivo,
    required String periodMonth,
    required String periodYear,
    required double monto,
    required String tipoCalculo,
  }) async {
    final body = {
      "motivo": motivo,
      "period_month": periodMonth,
      "period_year": periodYear,
      "monto": monto.toString(), 
      "tipo_calculo": tipoCalculo,
    };

    final response = await apiClient.post(
      '/api/admin/contributions',
      operationName: 'createContribution',
      data: body,
    );

    return CreateContributionResponseModel.fromJson(response);
  }

  Future<ContributionSimulationModel> simulateContribution({
    required double monto,
    required String tipoCalculo,
  }) async {
    final response = await apiClient.post(
      '/api/admin/contributions/simulate',
      operationName: 'simulateContribution',
      data: {
        "monto": monto,
        "tipo_calculo": tipoCalculo
      },
    );
    return ContributionSimulationModel.fromJson(response['data']);
  }
}
