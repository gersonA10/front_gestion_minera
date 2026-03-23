import 'package:front_gestion_minera/modules/treasury/data/models/income_request_model.dart';

import '../../domain/entity/entity.dart';
import '../../domain/entity/income_request_entity.dart';
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
  Future<FinancialReportEntity> getFinancialReport({
    String period = 'month',
    String? exactDate,
  }) async {
    return await datasource.getFinancialReport(
      period: period,
      exactDate: exactDate,
    );
  }

  @override
  Future<List<CashRegisterEntity>> getCashRegisters() async {
    return await datasource.getCashRegisters();
  }

  @override
  Future<IncomeResponseEntity> registerUrgentIncome(IncomeRequestEntity request) async {
    final requestModel = IncomeRequestModel.fromEntity(request);
    final response = await datasource.registerUrgentIncome(requestModel);
    return response;
  }


}
