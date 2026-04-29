import 'package:front_gestion_minera/modules/machinery/domain/entity/entity.dart';

abstract class MachineryRepository {
  Future<MetricsMachineryEntity> getMetricsMachinery();

  Future<InventoryMachineryEntity> getInventoryMachinery({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
    String? type,
  });
  Future<List<TypeMachineryEntity>> getTypeMachinery();
  Future<DetailMaintenanceResponseEntity> getDetailMachinery({required String machineId});

  Future<MaintenanceHistoryResponseEntity> getMaintenanceHistory({
    required String machineId,
    int page = 1,
    int limit = 10,
  });

  Future<RegisterMachineryResponseEntity> registerMachinery(
    RegisterMachineryRequestEntity request,
  );
   Future<CreateMaintenanceResponseEntity> createMaintenanceRequest(
    CreateMaintenanceRequestEntity requestModel,
  );

  Future<List<FailureTypeEntity>> getFailureTypes();
  Future<CloseUpOfAMachineResponseEntity> getCloseUpOfAMachine({
    required String machineId,
    int page = 1,
    int limit = 10,
  });
}
