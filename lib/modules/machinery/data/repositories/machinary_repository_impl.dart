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
  Future<InventoryMachineryEntity> getInventoryMachinery({int page = 1, int limit = 10}) {
    return datasource.getInvetoryMachinery();
  }
  
}