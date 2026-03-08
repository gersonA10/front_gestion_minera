import 'package:front_gestion_minera/modules/partners/domain/entity/loan_histori_entity.dart';

import '../../domain/repositories/repository.dart';
import '../datasource/datasource.dart';

class LoanHistoryRepositoryImpl extends LoanHistoryRepository {
  final LoanHistoryDatasource datasource;
  LoanHistoryRepositoryImpl({required this.datasource});

  @override
  Future<List<LoanHistoryDataEntity>> getLoanHistory() async {
    return await datasource.getLoanHistory();
  }

  @override
  Future<List<LoanHistoryDataEntity>> getLoanHistoryStatus(
    String status,
  ) async {
    return await datasource.getLoanHistoryStatus(status);
  }
}
