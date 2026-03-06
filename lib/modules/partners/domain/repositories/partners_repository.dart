import '../entity/entity.dart';

abstract class PartnersRepository {
  Future<List<ContributeHistoryDataEntity>> getcontributeHistory();
  Future<List<ContributeHistoryDataEntity>> getcontributeHistoryWeek();
  Future<List<ContributeHistoryDataEntity>> getcontributeHistoryMonth(
    String date,
  );
  Future<List<ContributeHistoryDataEntity>> getcontributeHistoryYear(
    String date,
  );
}
