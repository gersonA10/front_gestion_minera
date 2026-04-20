import '../../../../core/networking/http_services.dart';
import '../../domain/entity/entity.dart';
import '../models/model.dart';

class MachineryDatasource {
  final ApiClient apiClient;

  MachineryDatasource({required this.apiClient});

  Future<MetricsMachineryModel> getMetricsMachine() async {
    final response = await apiClient.get(
      '/api/machinery/stats',
      operationName: 'metricsMachinery',
    );
    return MetricsMachineryModel.fromJson(response['data'] ?? []);
  }

  Future<InventoryMachineryResponseModel> getInventoryMachinery({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
    String? type,
  }) async {
    final Map<String, dynamic> queryParameters = {'page': page, 'limit': limit};

    if (search != null && search.isNotEmpty) queryParameters['search'] = search;
    if (status != null && status != 'TODOS') queryParameters['status'] = status;
    if (type != null && status != 'TODOS') queryParameters['type'] = type;

    final response = await apiClient.get(
      '/api/machinery',
      queryParameters: queryParameters,
      operationName: 'InventoryMachinery',
    );
    return InventoryMachineryResponseModel.fromJson(response);
  }
}
