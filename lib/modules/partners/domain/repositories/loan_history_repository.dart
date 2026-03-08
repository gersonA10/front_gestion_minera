import '../entity/entity.dart';

abstract class LoanHistoryRepository {
  Future<List<LoanHistoryDataEntity>> getLoanHistory();
  Future<List<LoanHistoryDataEntity>> getLoanHistoryStatus(String status);
}
