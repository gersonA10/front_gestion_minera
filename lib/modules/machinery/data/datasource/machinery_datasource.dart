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

  Future<InventoryMachineryResponseModel> getInvetoryMachinery({
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, dynamic> queryParameters = {'page': page, 'limit': limit};
    final response = await apiClient.get(
      '/api/machinery',
      queryParameters: queryParameters,
      operationName: 'InventoryMachinery',
    );
    return InventoryMachineryResponseModel.fromJson(response);
  }
}
