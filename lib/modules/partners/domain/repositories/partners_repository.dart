import '../entity/entity.dart';

abstract class PartnersRepository {
  Future<List<LoanHistoryDataEntity>> getcontributeHistoryWeek();
  Future<List<LoanHistoryDataEntity>> getcontributeHistoryMonth(String date);
  Future<List<LoanHistoryDataEntity>> getcontributeHistoryYear(String date);
}
