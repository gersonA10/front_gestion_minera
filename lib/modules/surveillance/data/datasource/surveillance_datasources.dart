import 'package:front_gestion_minera/core/networking/http_services.dart';
import 'package:front_gestion_minera/modules/surveillance/data/models/surveillance_models.dart';

class SurveillanceDatasources {
  final ApiClient apiClient;
  SurveillanceDatasources({required this.apiClient});

  Future<Map<String, dynamic>> monitoringTray({
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, dynamic> queryParameters = {'page': page, 'limit': limit};

    final response = await apiClient.get(
      'api/viewRequests/history',
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
    }; //MonitoringTrayModel.fromJson(response);
  }
}
