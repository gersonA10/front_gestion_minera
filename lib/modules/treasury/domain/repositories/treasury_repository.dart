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
  Future<PaginatedGoldBatchesEntity> getGoldBatches({
    int page = 1,
    int limit = 10,
    String? status,
  });
  Future<ConfirmPaymentResponseEntity> confirmPayment(
    String idCash,
    ConfirmPaymentRequetsEntity confirmPaymentRequets,
  );
  Future<RejectAnApplicationResponseEntity> rejectAnApplication(
    String idCash,
    String reason,
  );

  Future<PaymentHistoryResponseEntity> getPaymentHistory({
    int page = 1,
    int limit = 10,
  });

  Future<InternalLoansResponseEntity> getInternalLoans({
    String? status,
    String? search,
    int page = 1,
    int limit = 10,
  });

  Future<TransactionDetailsResponseEntity> getTransactionDetails(
    String idTansaction,
  );
  Future<NewExtractionResponseEntiy> newExtraction(
    NewExtractionRequetsEntity newExtractionRequets,
  );

  Future<SalePreviewResponseEntity> previewSale(double gramsToSell);

  Future<RegisterSaleResponseEntity> registerSale(
    RegisterSaleRequestEntity request,
  );

  Future<ApplyForALoanResponseEntity> applyForALoan(
    String lenderName,
    double amount,
    int termMonths,
    double annualInterestRate,
    String startDate,
    String cajaDestinoId,
  );
  Future<NewLoansResponseEntity> postNewLoansSimulate(double amount, int termMonths, String annualInterestRate, String startDate);
   Future<LoanDetailsResponseEntity> getloanDatails(
    String idLoan,
  );

  Future<DistributionHistoryResponseEntity> getDistributionHistory({
    int page = 1,
    int limit = 10,
  });
}
