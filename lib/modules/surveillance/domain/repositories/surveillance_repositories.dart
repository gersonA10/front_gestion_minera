import '../entity/entity.dart';

abstract class SurveillanceRepositories {
  Future<MonitoringTrayEntity> monitoringTray({int page = 1, int limit = 10});
}
