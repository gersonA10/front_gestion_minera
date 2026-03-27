import '../entity/entity.dart';
import '../entity/income_request_entity.dart';

abstract class TreasuryRepository {
  Future<TreasuryMetricsEntity> getMetrics();
  Future<BondBalanceResponseEntity> getBondBalence();
  Future<PendingApplicationsResponseEntity> getPendingApplications();
  Future<DetailsofanapplicationResponseEntity> getDetailsofanapplication(
    String id,
  );
  Future<CashResponseEntity> getCash();
  Future<ListOfPendingRequestsResponseEntity> listOfPendingRequests({
    int page = 1,
    int limit = 10,
  });

  Future<FinancialReportEntity> getFinancialReport({
    String period = 'month',
    String? exactDate,
  });

  Future<IncomeResponseEntity> registerUrgentIncome(
    IncomeRequestEntity request,
  );

  Future<ExpenseResponseEntity> registerUrgentExpense(
    ExpenseRequestEntity request,
  );

  Future<List<CashRegisterEntity>> getCashRegisters();

  Future<GoldInventoryEntity> getGoldInventory();
  Future<PaginatedGoldBatchesEntity> getGoldBatches({int page = 1, int limit = 10});
}
