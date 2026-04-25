import 'package:front_gestion_minera/modules/machinery/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/machinery/domain/repositories/repository.dart';
import '../datasource/datasource.dart';

class MachineryRepositoryImpl extends MachineryRepository {
  final MachineryDatasource datasource;

  MachineryRepositoryImpl({required this.datasource});

  @override
  Future<MetricsMachineryEntity> getMetricsMachinery() {
    return datasource.getMetricsMachine();
  }

  @override
  Future<InventoryMachineryEntity> getInventoryMachinery({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
    String? type,
  }) {
    return datasource.getInventoryMachinery(
      page: page,
      limit: limit,
      search: search,
      status: status,
      type: type,
    );
  }

  @override
  Future<List<TypeMachineryEntity>> getTypeMachinery() {
    return datasource.getTypesMachinery();
  }

  @override
  Future<RegisterMachineryResponseEntity> registerMachinery(
    RegisterMachineryRequestEntity request,
  ) {
    return datasource.registerMachinery(request);
  }

  @override
  Future<MaintenanceHistoryResponseEntity> getMaintenanceHistory({
    required String machineId,
    int page = 1,
    int limit = 10,
  }) {
    return datasource.getMaintenanceHistory(
      machineId: machineId,
      page: page,
      limit: limit,
    );
  }
  
  @override
  Future<DetailMaintenanceResponseEntity> getDetailMachinery({required String machineId}) {
    return datasource.getDetailMachinery(machineId: machineId);
  }
}
