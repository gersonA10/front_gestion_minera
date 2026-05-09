import 'package:front_gestion_minera/core/networking/http_services.dart';

import '../../domain/entity/entity.dart';
import '../models/model.dart';

class CampDatasource {
  final ApiClient apiClient;

  CampDatasource({required this.apiClient});

  Future<CampDashboardModel> getDashboard({int page = 1, int limit = 10}) async {
    final response = await apiClient.get(
      '/api/camp/dashboard',
      operationName: 'getCampDashboard',
      queryParameters: {'page': page, 'limit': limit},
    );
    return CampDashboardModel.fromJson(response);
  }

  Future<Map<String, dynamic>> getTransactionHistory({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      'status': (status == null || status.isEmpty) ? 'TODOS' : status,
    };

    final response = await apiClient.get(
      '/api/camp/requests/history',
      operationName: 'getCampTransactionHistory',
      queryParameters: queryParams,
    );

    final List<dynamic> data = response['data'] ?? [];
    final Map<String, dynamic> meta = response['meta'] ?? {};

    return {
      'items': data.map((item) => TransactionHistoryModel.fromJson(item)).toList(),
      'has_more': meta['has_more'] ?? false,
      'total_records': meta['total_records'] ?? 0,
    };
  }

  Future<CampRecentRequestModel> createRequest(
    CreateCampRequestEntity request,
  ) async {
    final model = CreateCampRequestModel.fromEntity(request);
    final response = await apiClient.post(
      '/api/camp/requests',
      operationName: 'createCampRequest',
      data: model.toJson(),
    );
    return CampRecentRequestModel.fromJson(response['data']);
  }

  Future<RequestDetailModel> getRequestDetail(String requestId) async {
    final response = await apiClient.get(
      '/api/camp/requests/$requestId',
      operationName: 'getCampRequestDetail',
    );
    return RequestDetailModel.fromJson(response['data']);
  }

  Future<String> _uploadReceipt(String filePath) async {
    final response = await apiClient.postFormData(
      '/api/upload/camp-receipt',
      operationName: 'uploadCampReceipt',
      data: {},
      files: [
        {
          'name': 'file',
          'path': filePath,
          'filename': filePath.split('/').last,
        },
      ],
    );
    return response['data']['url'] as String;
  }

  Future<CloseRequestResultModel> closeRequest(
    String requestId,
    CloseRequestEntity request,
  ) async {
    final model = CloseRequestModel.fromEntity(request);
    final evidenceUrl = await _uploadReceipt(model.evidencePath);
    final response = await apiClient.post(
      '/api/camp/requests/$requestId/close',
      operationName: 'closeCampRequest',
      data: model.toJson(evidenceUrl),
    );
    return CloseRequestResultModel.fromJson(response['data']);
  }
}
