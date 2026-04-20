import 'package:front_gestion_minera/modules/machinery/domain/entity/entity.dart';

abstract class MachineryRepository {

  Future<MetricsMachineryEntity> getMetricsMachinery();
  
  Future<InventoryMachineryEntity> getInventoryMachinery({
    int page = 1,
    int limit = 5,
    String? search,
    String? status,
    String? type
  });
}
