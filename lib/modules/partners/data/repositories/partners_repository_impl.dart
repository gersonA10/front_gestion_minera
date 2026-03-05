import '../../domain/entity/entity.dart';
import '../../domain/repositories/repository.dart';
import '../datasource/datasource.dart';

class PartnersRepositoryImpl extends PartnersRepository {
  final PartnersDatasource datasource;
  PartnersRepositoryImpl({required this.datasource});

  @override
  Future<List<LoanHistoryDataEntity>> getcontributeHistory() async {
    return await datasource.getcontributeHistory();
  }

  @override
  Future<List<LoanHistoryDataEntity>> getcontributeHistoryWeek() async {
    return await datasource.getcontributeHistoryWeek();
  }

  @override
  Future<List<LoanHistoryDataEntity>> getcontributeHistoryMonth(
    String date,
  ) async {
    return await datasource.getcontributeHistoryMonth(date);
  }

  @override
  Future<List<LoanHistoryDataEntity>> getcontributeHistoryYear(
    String date,
  ) async {
    return await datasource.getcontributeHistoryYear(date);
  }
}
