import 'package:front_gestion_minera/core/networking/http_services.dart';
import 'package:front_gestion_minera/modules/partners/data/models/request_history_model.dart';
import '../models/money_request_model.dart';
import '../models/money_request_response_model.dart';

class MoneyRequestDatasource {
  final ApiClient apiClient;

  MoneyRequestDatasource({required this.apiClient});

  Future<MoneyRequestResponseModel> submitMoneyRequest(
    MoneyRequestModel requestModel,
  ) async {
    final response = await apiClient.postFormData(
      '/api/requests/register',
      operationName: 'submitMoneyRequest',
      data: requestModel.toFormDataMap(), // Usamos el mapeo de los textos
      files: [
        {
          'name': 'evidencia_url',
          'path': requestModel.evidenceUrlPath,
          'filename': requestModel.evidenceUrlPath.split('/').last,
        },
      ],
    );

    return MoneyRequestResponseModel.fromJson(response);
  }


  Future<Map<String, dynamic>> getHistory({
    String? status,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, dynamic> queryParameters = {'page': page, 'limit': limit};

    if (status != null && status.toLowerCase() != 'todos') {
      queryParameters['status'] = status.toLowerCase();
    }

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    final response = await apiClient.get(
      '/api/requests/history',
      operationName: 'getMoneyRequestHistory',
      queryParameters: queryParameters,
    );

    final List<dynamic> data = response['data'] ?? [];
    final Map<String, dynamic> meta = response['meta'] ?? {};

    return {
      'items': data.map((item) => RequestHistoryModel.fromJson(item)).toList(),
      'has_more_data': meta['has_more_data'] ?? false,
    };
  }
}
