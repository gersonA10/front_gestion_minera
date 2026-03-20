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
}
