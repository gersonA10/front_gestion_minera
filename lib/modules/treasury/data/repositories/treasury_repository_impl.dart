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
  Future<CashResponseEntity> getCash() async {
    return await datasource.getCash();
  }

  @override
  Future<ListOfPendingRequestsResponseEntity> listOfPendingRequests({
    int page = 1,
    int limit = 10,
  }) async {
    final result = await datasource.listOfPendingRequests(
      page: page,
      limit: limit,
    );
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
  Future<IncomeResponseEntity> registerUrgentIncome(
    IncomeRequestEntity request,
  ) async {
    final requestModel = IncomeRequestModel.fromEntity(request);
    final response = await datasource.registerUrgentIncome(requestModel);
    return response;
  }

  @override
  Future<ConfirmPaymentResponseEntity> confirmPayment(
    String idCash,
    ConfirmPaymentRequetsEntity confirmPaymentRequets,
  ) async {
    final requestModel = ConfirmPaymentRequestModel.fromEntity(
      confirmPaymentRequets,
    );
    final response = await datasource.confirmPayment(idCash, requestModel);
    return response;
  }

  @override
  Future<RejectAnApplicationResponseEntity> rejectAnApplication(
    String idCash,
    String reason,
  ) async {
    return await datasource.rejectAnApplication(idCash, reason);
  }

  @override
  Future<ExpenseResponseEntity> registerUrgentExpense(
    ExpenseRequestEntity request,
  ) async {
    final requestModel = ExpenseRequestModel.fromEntity(request);
    final response = await datasource.registerUrgentExpense(requestModel);
    return response;
  }

  @override
  Future<TransferResponseEntity> registerUrgentTransfer(
    TransferRequestEntity request,
  ) async {
    final requestModel = TransferRequestModel.fromEntity(request);
    return await datasource.registerUrgentTransfer(requestModel);
  }

  @override
  Future<GoldInventoryEntity> getGoldInventory() async {
    return await datasource.getGoldInventory();
  }

  @override
  Future<PaginatedGoldBatchesEntity> getGoldBatches({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final result = await datasource.getGoldBatches(
      page: page,
      limit: limit,
      status: status,
    );
    return result;
  }

  @override
  Future<PaymentHistoryResponseEntity> getPaymentHistory({
    int page = 1,
    int limit = 10,
    String? period,
    String? exactDate,
  }) async {
    final result = await datasource.getPaymentHistory(
      page: page,
      limit: limit,
      period: period,
      exactDate: exactDate,
    );
    final models = result['items'] as List<PaymentHistoryItemModel>;
    return PaymentHistoryResponseEntity(
      summary: result['summary'] as PaymentHistorySummaryEntity,
      items: models,
      hasMoreData: result['has_more_data'] as bool,
      totalRecords: result['total_records'] as int? ?? 0,
    );
  }

  @override
  Future<InternalLoansResponseEntity> getInternalLoans({
    String? status,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final result = await datasource.internalLoans(
      status: status,
      search: search,
      page: page,
      limit: limit,
    );
    final models = result['items'] as List<InternalLoansResponseModel>;
    return InternalLoansResponseEntity(
      items: models.map((model) => model.toEntity()).toList(),
      hasMore: result['has_more_data'] as bool,
      totalRecords: result['total_records'] as int? ?? 0,
    );
  }

  @override
  Future<TransactionDetailsResponseEntity> getTransactionDetails(
    String idTansaction,
  ) async {
    return await datasource.getTransactionDetails(idTansaction);
  }

  @override
  Future<NewExtractionResponseEntiy> newExtraction(
    NewExtractionRequetsEntity newExtractionRequets,
  ) async {
    final requestModel = NewExtractionRequestModel.fromEntity(
      newExtractionRequets,
    );
    final response = await datasource.newExtraction(requestModel);
    return response;
  }

  @override
  Future<SalePreviewResponseEntity> previewSale(double gramsToSell) async {
    return await datasource.previewSale(gramsToSell);
  }

  @override
  Future<RegisterSaleResponseEntity> registerSale(
    RegisterSaleRequestEntity request,
  ) async {
    final requestModel = RegisterSaleRequestModel.fromEntity(request);
    return await datasource.registerSale(requestModel);
  }

  @override
  Future<NewLoansResponseEntity> postNewLoansSimulate(
    double amount,
    int termMonths,
    String annualInterestRate,
    String startDate,
  ) async {
    return await datasource.postNewLoansSimulate(
      amount,
      termMonths,
      annualInterestRate,
      startDate,
    );
  }

  @override
  Future<ApplyForALoanResponseEntity> applyForALoan(
    String lenderName,
    double amount,
    int termMonths,
    double annualInterestRate,
    String startDate,
    String cajaDestinoId,
  ) async {
    return await datasource.postApplyForAloan(
      lenderName,
      amount,
      termMonths,
      annualInterestRate,
      startDate,
      cajaDestinoId,
    );
  }

  @override
  Future<LoanDetailsResponseEntity> getloanDatails(String idLoan) async {
    return await datasource.getloanDatails(idLoan);
  }

  @override
  Future<DistributionHistoryResponseEntity> getDistributionHistory({
    int page = 1,
    int limit = 10,
  }) async {
    final result = await datasource.getDistributionHistory(
      page: page,
      limit: limit,
    );
    final models = result['items'] as List<DistributionHistoryItemModel>;
    return DistributionHistoryResponseEntity(
      items: models,
      hasMore: result['has_more'] as bool,
      totalRecords: result['total_records'] as int? ?? 0,
    );
  }

  @override
  Future<DistributionDetailResponseEntity> getDistributionDetail(
    String distributionId, {
    int page = 1,
    int limit = 10,
  }) async {
    final result = await datasource.getDistributionDetail(
      distributionId,
      page: page,
      limit: limit,
    );
    return DistributionDetailResponseEntity(
      header: result['header'] as DistributionDetailHeaderModel,
      membersList:
          result['members_list'] as List<DistributionDetailMemberModel>,
      hasMore: result['has_more'] as bool,
      totalRecords: result['total_records'] as int? ?? 0,
    );
  }

  @override
  Future<LotDetailsDataEntity> getLotDetails(String batchId) async {
    return await datasource.lotDetails(batchId);
  }

  @override
  Future<PayTheFeeResponseEntity> payTheFee(
    PayTheFeeRequetsEntity payTheFeeRequest,
    String idLoan,
    String idQuota,
  ) async {
    final requestModel = PayTheFeeRequestModel.fromEntity(payTheFeeRequest);
    final response = await datasource.payTheFee(requestModel, idLoan, idQuota);
    return response;
  }
}
