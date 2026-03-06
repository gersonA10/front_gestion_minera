import '../../domain/entity/entity.dart';
import '../../domain/repositories/repository.dart';
import '../datasource/datasource.dart';

class PartnersRepositoryImpl extends PartnersRepository {
  final PartnersDatasource datasource;
  PartnersRepositoryImpl({required this.datasource});

  @override
  Future<List<ContributeHistoryDataEntity>> getcontributeHistory() async {
    return await datasource.getcontributeHistory();
  }

  @override
  Future<List<ContributeHistoryDataEntity>> getcontributeHistoryWeek() async {
    return await datasource.getcontributeHistoryWeek();
  }

  @override
  Future<List<ContributeHistoryDataEntity>> getcontributeHistoryMonth(
    String date,
  ) async {
    return await datasource.getcontributeHistoryMonth(date);
  }

  @override
  Future<List<ContributeHistoryDataEntity>> getcontributeHistoryYear(
    String date,
  ) async {
    return await datasource.getcontributeHistoryYear(date);
  }
}
