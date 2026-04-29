import '../../../../core/networking/http_services.dart';
import '../../domain/entity/entity.dart';
import '../models/model.dart';

class MachineryDatasource {
  final ApiClient apiClient;

  MachineryDatasource({required this.apiClient});

  Future<CreateMaintenanceResponseModel> createMaintenanceRequest(
    CreateMaintenanceRequestModel requestModel,
  ) async {
    final response = await apiClient.postFormData(
      '/api/machinery/maintenances',
      operationName: 'createMaintenanceRequest',
      data: requestModel.toFormDataMap(),
      files: [
        {
          'name': 'evidence_url',
          'path': requestModel.evidenceUrlPath,
          'filename': requestModel.evidenceUrlPath.split('/').last,
        },
      ],
    );
    return CreateMaintenanceResponseModel.fromJson(response['data']);
  }

  Future<MetricsMachineryModel> getMetricsMachine() async {
    final response = await apiClient.get(
      '/api/machinery/stats',
      operationName: 'metricsMachinery',
    );
    return MetricsMachineryModel.fromJson(response['data']);
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
    if (type != null && type != 'TODOS') queryParameters['type'] = type;

    final response = await apiClient.get(
      '/api/machinery',
      queryParameters: queryParameters,
      operationName: 'InventoryMachinery',
    );
    return InventoryMachineryResponseModel.fromJson(response);
  }

  Future<MaintenanceHistoryResponseEntity> getMaintenanceHistory({
    required String machineId,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await apiClient.get(
      '/api/machinery/machine/$machineId',
      queryParameters: {'page': page, 'limit': limit},
      operationName: 'maintenanceHistory',
    );
    return MaintenanceHistoryResponseModel.fromJson(response);
  }

  Future<RegisterMachineryResponseModel> registerMachinery(
    RegisterMachineryRequestEntity request,
  ) async {
    final model = RegisterMachineryRequestModel.fromEntity(request);
    final response = await apiClient.postFormData(
      '/api/machinery/register',
      operationName: 'registerMachinery',
      data: model.toFormDataMap(),
      files: [
        {
          'name': 'photo_url',
          'path': model.photoPath,
          'filename': model.photoPath.split('/').last,
        },
      ],
    );
    return RegisterMachineryResponseModel.fromJson(response['data']);
  }

  Future<List<TypeMachineryModel>> getTypesMachinery() async {
    final response = await apiClient.get(
      '/api/machinery/types',
      operationName: 'typesMachinery',
    );

    final List data = response['data'];

    return data.map((e) => TypeMachineryModel.fromJson(e)).toList();
  }

  Future<DetailMaintenanceResponseEntity> getDetailMachinery({
    required String machineId,
  }) async {
    final response = await apiClient.get(
      '/api/machinery/maintenance/$machineId',
      operationName: 'detailMachinery',
    );
    return DetailMaintenanceResponseModel.fromJson(response['data']);
  }
  Future<List<FailureTypeModel>> getFailureTypes() async {
    final response = await apiClient.get(
      '/api/maintenance/failure-types',
      operationName: 'failureTypes',
    );
    final List data = response['data'];
    return data.map((e) => FailureTypeModel.fromJson(e)).toList();
  }

  Future<CloseUpOfAMachineResponseEntity> getCloseUpOfAMachine({
    required String machineId,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await apiClient.get(
      '/api/machinery/$machineId',
      queryParameters: {'page': page, 'limit': limit},
      operationName: 'closeUpOfAMachine',
    );
    return CloseUpOfAMachineResponseModel.fromJson(response);
  }
}
