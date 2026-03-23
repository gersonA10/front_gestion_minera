
import '../../domain/entity/entity.dart';
import '../../domain/entity/income_request_entity.dart';
import '../../domain/repositories/repository.dart';
import '../datasource/datasource.dart';
import '../models/model.dart';

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
  
  @override
  Future<ListOfPendingRequestsResponseEntity> listOfPendingRequests({int page = 1, int limit = 10}) async {
    final result = await datasource.listOfPendingRequests(page: page, limit: limit);
    final models = result['items'] as List<ListOfPendingRequestsResponseModel>;
    return ListOfPendingRequestsResponseEntity(
      items: models.map((model) => model.toEntity()).toList(),
      hasMoreData: result['has_more_data'] as bool,
      totalRecords: result['total_records'] as int? ?? 0,
    );
    
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
