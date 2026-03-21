import '../../domain/entity/entity.dart';
import '../../domain/repositories/repository.dart';
import '../datasource/datasource.dart';

class TreasuryRepositoryImpl implements TreasuryRepository {
  final TreasuryDatasource datasource;

  TreasuryRepositoryImpl({required this.datasource});

  @override
  Future<TreasuryMetricsEntity> getMetrics() async {
    return await datasource.getMetrics();
  }

  @override
  Future<BondBalanceResponseEntity> getBondBalence() async {
    return await datasource.getBondBalence();
  }

  @override
  Future<PendingApplicationsResponseEntity> getPendingApplications() async {
    return await datasource.getPendingApplications();
  }

  @override
  Future<DetailsofanapplicationResponseEntity> getDetailsofanapplication(
    String id,
  ) async {
    return await datasource.getDetailsofanapplication(id);
  }
  
  @override
  Future<CashResponseEntity> getCash()async {
    return await datasource.getCash();
  }
}
