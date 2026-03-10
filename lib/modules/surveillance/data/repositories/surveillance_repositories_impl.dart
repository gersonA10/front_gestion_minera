import 'package:front_gestion_minera/modules/surveillance/data/models/surveillance_models.dart';
import 'package:front_gestion_minera/modules/surveillance/domain/entity/surveillance_entity.dart';

import '../../domain/repositories/repository.dart';
import '../datasource/datasource.dart';

class SurveillanceRepositoriesImpl extends SurveillanceRepositories {
  final SurveillanceDatasources datasources;
  SurveillanceRepositoriesImpl({required this.datasources});

  @override
  Future<MonitoringTrayEntity> monitoringTray({
    int page = 1,
    int limit = 10,
  }) async {
    final result = await datasources.monitoringTray(page: page, limit: limit);
    final models = result['items'] as List<MonitoringTrayDataModel>;
    return MonitoringTrayEntity(
      items: models.map((model) => model.toEntity()).toList(),
      hasMoreData: result['has_more_data'] as bool,
    );
  }
}
