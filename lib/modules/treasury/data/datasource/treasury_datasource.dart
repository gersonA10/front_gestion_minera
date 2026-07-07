
import '../../../../core/networking/http_services.dart';
import '../../domain/entity/entity.dart';
import '../models/model.dart';

class TreasuryDatasource {
  final ApiClient apiClient;

  TreasuryDatasource({required this.apiClient});

  Future<TreasuryMetricsModel> getMetrics() async {
    final response = await apiClient.get(
      '/api/treasury/dashboard/home',
      operationName: 'getTreasuryMetrics',
    );
    return TreasuryMetricsModel.fromJson(response['data']);
  }

  Future<BondBalanceResponseModel> getBondBalence() async {
    final response = await apiClient.get(
      '/api/treasury/finance/balances',
      operationName: 'getBondBalence',
    );
    return BondBalanceResponseModel.fromJson(response['data']);
  }

  Future<PendingApplicationsResponseEntity> getPendingApplications() async {
    final response = await apiClient.get(
      '/api/treasury/requests/recent',
      operationName: 'getPendingApplications',
    );
    return PendingApplicationsResponseModel.fromJson(response);
  }

  Future<DetailsofanapplicationResponseEntity> getDetailsofanapplication(
    String id,
  ) async {
    final response = await apiClient.get(
      '/api/treasury/requests/$id',
      operationName: 'getDetailsofanapplication',
    );
    return DetailsofanapplicationResponseModel.fromJson(response);
  }

  Future<CashResponseEntity> getCash() async {
    final response = await apiClient.get(
      '/api/treasury/cash-registers',
      operationName: 'getCash',
    );
    return CashResponseModel.fromJson(response);
  }

  Future<Map<String, dynamic>> listOfPendingRequests({
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, dynamic> queryParameters = {'page': page, 'limit': limit};

    final response = await apiClient.get(
      '/api/treasury/requests/pending',
      operationName: 'listOfPendingRequests',
      queryParameters: queryParameters,
    );
    final List<dynamic> data = response['data'] ?? [];
    final Map<String, dynamic> meta = response['meta'] ?? {};
    return {
      'items': data
          .map((item) => ListOfPendingRequestsResponseModel.fromJson(item))
          .toList(),
      'has_more_data': meta['has_more_data'] ?? false,

      'total_records': meta['total_records'] ?? 0,
    };
  }

  Future<Map<String, dynamic>> getPendingReconciliations({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final Map<String, dynamic> queryParameters = {'page': page, 'limit': limit};
    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    final response = await apiClient.get(
      '/api/treasury/reconciliations/pending',
      operationName: 'getPendingReconciliations',
      queryParameters: queryParameters,
    );
    final List<dynamic> data = response['data'] ?? [];
    final Map<String, dynamic> meta = response['meta'] ?? {};
    return {
      'items': data
          .map((item) => ReconciliationItemModel.fromJson(item))
          .toList(),
      'has_more_data': meta['has_more_data'] ?? false,
      'total_records': meta['total_records'] ?? 0,
    };
  }

  Future<ExecuteReconciliationResultEntity> executeReconciliation(
    String requestId,
    String cajaOrigenId,
    String? nota,
  ) async {
    final Map<String, dynamic> data = {'caja_origen_id': cajaOrigenId};
    if (nota != null && nota.trim().isNotEmpty) {
      data['nota'] = nota.trim();
    }
    final response = await apiClient.post(
      '/api/treasury/requests/$requestId/reconcile',
      operationName: 'executeReconciliation',
      data: data,
    );
    return ExecuteReconciliationResponseModel.fromJson(response);
  }

  Future<FinancialReportModel> getFinancialReport({
    String period = 'month',
    String? exactDate,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{'period': period};
    if (exactDate != null && exactDate.isNotEmpty) {
      queryParams['exact_date'] = exactDate;
    }
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['start_date'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['end_date'] = endDate;
    }

    final response = await apiClient.get(
      '/api/treasury/reports/financial',
      queryParameters: queryParams,
      operationName: 'getFinancialReport',
    );

    return FinancialReportModel.fromJson(response['data']);
  }

  Future<List<CashRegisterModel>> getCashRegisters() async {
    final response = await apiClient.get(
      '/api/treasury/cash-registers',
      operationName: 'getCashRegisters',
    );

    final List data = response['data'];
    return data.map((e) => CashRegisterModel.fromJson(e)).toList();
  }

  Future<IncomeResponseModel> registerUrgentIncome(
    IncomeRequestModel incomeRequestModel,
  ) async {
    final response = await apiClient.postFormData(
      '/api/treasury/urgent/income',
      data: incomeRequestModel.toFormDataMap(),
      operationName: 'registerUrgentIncome',
      files: [
        {
          'name': 'evidencia',
          'path': incomeRequestModel.evidenceUrlPath,
          'filename': incomeRequestModel.evidenceUrlPath.split('/').last,
        },
      ],
    );

    return IncomeResponseModel.fromJson(response['data']);
  }

  Future<ConfirmPaymentResponseModel> confirmPayment(
    String idRequest,
    ConfirmPaymentRequestModel confirmPaymentRequets,
  ) async {
    final response = await apiClient.postFormData(
      '/api/treasury/requests/$idRequest/disburse',
      data: confirmPaymentRequets.toFormDataMap(),
      operationName: 'confirmPayment',
      files: [
        {
          'name': 'comprobante',
          'path': confirmPaymentRequets.comprobante,
          'filename': confirmPaymentRequets.comprobante.split('/').last,
        },
      ],
    );
    return ConfirmPaymentResponseModel.fromJson(response);
  }

  Future<GoldInventoryModel> getGoldInventory() async {
    final response = await apiClient.get(
      '/api/treasury/gold',
      operationName: 'getGoldInventory',
    );
    return GoldInventoryModel.fromJson(response['data']);
  }

  Future<PaginatedGoldBatchesEntity> getGoldBatches({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final queryParameters = {'page': page, 'limit': limit, 'status': ?status};
    final response = await apiClient.get(
      '/api/treasury/batches',
      operationName: 'getGoldBatches',
      queryParameters: queryParameters,
    );

    final List<dynamic> data = response['data'] ?? [];
    final Map<String, dynamic> meta = response['meta'] ?? {};

    return PaginatedGoldBatchesEntity(
      batches: data.map((item) => GoldBatchModel.fromJson(item)).toList(),
      hasMore: meta['has_more'] ?? false,
      totalRecords: meta['total_records'] ?? 0,
    );
  }

  Future<SaleHistoryResponseEntity> getHistorySales({
    int page = 1,
    int limit = 5,
    String? status,
  }) async {
    final queryParameters = {'page': page, 'limit': limit, 'status': ?status};
    final response = await apiClient.get(
      '/api/treasury/sales/history',
      operationName: 'getStatsSalesHistory',
      queryParameters: queryParameters,
    );

    final List<dynamic> data = response['data'];
    final Map<String, dynamic> meta = response['meta'];
    return SaleHistoryResponseEntity(
      meta: StatsSaleHistoryModel.fromJson(meta),
      sales: data.map((item) => SaleHistoryModel.fromJson(item)).toList(),
    );
  }

  Future<RejectAnApplicationResponseEntity> rejectAnApplication(
    String idCash,
    String reason,
  ) async {
    final response = await apiClient.post(
      '/api/treasury/requests/$idCash/reject-payment',
      data: {"reason": reason},
      operationName: 'rejectAnApplication',
    );

    return RejectAnApplicationResponseModel.fromJson(response);
  }

  Future<ExpenseResponseModel> registerUrgentExpense(
    ExpenseRequestModel expenseRequestModel,
  ) async {
    final response = await apiClient.postFormData(
      '/api/treasury/urgent/expense',
      data: expenseRequestModel.toFormDataMap(),
      operationName: 'registerUrgentIncome',
      files: [
        {
          'name': 'evidencia',
          'path': expenseRequestModel.evidenceUrlPath,
          'filename': expenseRequestModel.evidenceUrlPath.split('/').last,
        },
      ],
    );

    return ExpenseResponseModel.fromJson(response['data']);
  }

  Future<TransferResponseModel> registerUrgentTransfer(
    TransferRequestModel request,
  ) async {
    final response = await apiClient.post(
      '/api/treasury/urgent/transfer',
      data: request.toJson(),
      operationName: 'registerUrgentTransfer',
    );
    return TransferResponseModel.fromJson(response);
  }

  Future<Map<String, dynamic>> getPaymentHistory({
    int page = 1,
    int limit = 10,
    String? period,
    String? exactDate,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'page': page,
      'limit': limit,
      'period': period,
      'exact_date': exactDate,
    };

    final response = await apiClient.get(
      '/api/treasury/transactions/history',
      operationName: 'getPaymentHistory',
      queryParameters: queryParameters,
    );

    final List<dynamic> data = response['data'] ?? [];
    final Map<String, dynamic> meta = response['meta'] ?? {};
    final Map<String, dynamic> summary = response['summary'] ?? {};

    return {
      'items': data
          .map((item) => PaymentHistoryItemModel.fromJson(item))
          .toList(),
      'summary': PaymentHistorySummaryModel.fromJson(summary),
      'has_more_data': meta['has_more_data'] ?? false,
      'total_records': meta['total_records'] ?? 0,
    };
  }

  Future<Map<String, dynamic>> internalLoans({
    String? status,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, dynamic> queryParameters = {'page': page, 'limit': limit};

    if (status != null && status.toLowerCase() != 'todos') {
      queryParameters['status'] = status.toLowerCase();
    }

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }
    final response = await apiClient.get(
      '/api/treasury/corporate-loan',
      operationName: 'internalLoans',
      queryParameters: queryParameters,
    );
    final List<dynamic> data = response['data'] ?? [];
    final Map<String, dynamic> meta = response['meta'] ?? {};
    return {
      'items': data
          .map((item) => InternalLoansResponseModel.fromJson(item))
          .toList(),
      'has_more_data': meta['has_more_data'] ?? false,
      'total_records': meta['total_records'] ?? 0,
    };
  }

  Future<TransactionDetailsResponseEntity> getTransactionDetails(
    String idTansaction,
  ) async {
    final response = await apiClient.get(
      '/api/treasury/transactions/$idTansaction',
      operationName: 'getTransactionDetails',
    );
    return TransactionDetailsResponseModel.fromJson(response['data']);
  }

  Future<NewExtractionResponseModel> newExtraction(
    NewExtractionRequestModel newExtractionRequest,
  ) async {
    final response = await apiClient.postFormData(
      '/api/treasury/batches',
      data: newExtractionRequest.toFormDataMap(),
      operationName: 'newExtraction',
      files: [
        {
          'name': 'evidencia',
          'path': newExtractionRequest.evidencia,
          'filename': newExtractionRequest.evidencia.split('/').last,
        },
      ],
    );
    return NewExtractionResponseModel.fromJson(response);
  }

  Future<SalePreviewResponseEntity> previewSale(double gramsToSell) async {
    final response = await apiClient.post(
      '/api/treasury/sales/preview-fifo',
      data: {'grams_to_sell': gramsToSell},
      operationName: 'previewSale',
    );
    return SalePreviewResponseModel.fromJson(response['data']);
  }

  Future<RegisterSaleResponseEntity> registerSale(
    RegisterSaleRequestModel request,
  ) async {
    final response = await apiClient.postFormData(
      '/api/treasury/sales',
      data: request.toFormDataMap(),
      operationName: 'registerSale',
      files: [
        {
          'name': 'comprobante',
          'path': request.comprobante,
          'filename': request.comprobante.split('/').last,
        },
      ],
    );
    return RegisterSaleResponseModel.fromJson(response['data']);
  }

  Future<RegisterSaleResponseEntity> getSaleById(String idSale) async{
    final response = await apiClient.get(
      '/api/treasury/sales/$idSale', 
      operationName: 'getSaleById');
    return RegisterSaleResponseModel.fromJson(response['data']);
  }

  Future<NewLoansResponseEntity> postNewLoansSimulate(
    double amount,
    int termMonths,
    String annualInterestRate,
    String startDate,
  ) async {
    final response = await apiClient.post(
      '/api/treasury/corporate-loans/simulate',
      data: {
        "amount": amount,
        "term_months": termMonths,
        "annual_interest_rate": annualInterestRate,
        "start_date": startDate,
      },
      operationName: 'postNewLoansSimulate',
    );
    return NewLoansResponseModel.fromJson(response['data']);
  }

  Future<ApplyForALoanResponseEntity> postApplyForAloan(
    String lenderName,
    double amount,
    int termMonths,
    double annualInterestRate,
    String startDate,
    String cajaDestinoId,
  ) async {
    final data = {
      "lender_name": lenderName,
      "amount": amount,
      "term_months": termMonths,
      "annual_interest_rate": annualInterestRate,
      "start_date": startDate,
      "caja_destino_id": cajaDestinoId,
    };
    final response = await apiClient.post(
      '/api/treasury/corporate-loans',
      data: data,
      operationName: 'postApplyForAloan',
    );
    return ApplyForALoanResponseModel.fromJson(response['data']);
  }

  Future<LoanDetailsResponseEntity> getloanDatails(String idLoan) async {
    final response = await apiClient.get(
      '/api/treasury/corporate-loans/$idLoan',
      operationName: 'getloanDatails',
    );
    return LoanDetailsResponseModel.fromJson(response);
  }

  Future<Map<String, dynamic>> getDistributionDetail(
    String distributionId, {
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, dynamic> queryParameters = {'page': page, 'limit': limit};
    final response = await apiClient.get(
      '/api/treasury/distributions/$distributionId',
      operationName: 'getDistributionDetail',
      queryParameters: queryParameters,
    );
    final Map<String, dynamic> data = response['data'] ?? {};
    final Map<String, dynamic> meta = response['meta'] ?? {};
    final List<dynamic> membersList = data['members_list'] ?? [];
    return {
      'header': DistributionDetailHeaderModel.fromJson(
        data['header'] as Map<String, dynamic>,
      ),
      'members_list': membersList
          .map(
            (m) => DistributionDetailMemberModel.fromJson(
              m as Map<String, dynamic>,
            ),
          )
          .toList(),
      'has_more': meta['has_more'] ?? false,
      'total_records': meta['total_records'] ?? 0,
    };
  }

  Future<DividendPaymentResponseEntity> payDividend(
    String distributionId,
    String memberId,
    String cashRegisterId,
    String period,
    String evidenciaPath,
  ) async {
    final response = await apiClient.postFormData(
      '/api/treasury/distributions/$distributionId/members/$memberId/pay',
      data: {'cash_register_id': cashRegisterId, 'period': period},
      operationName: 'payDividend',
      files: [
        {
          'name': 'evidencia',
          'path': evidenciaPath,
          'filename': evidenciaPath.split('/').last,
        },
      ],
    );
    return DividendPaymentResponseModel.fromJson(response['data']);
  }

  Future<Map<String, dynamic>> getDistributionHistory({
    int page = 1,
    int limit = 10,
    int? year,
  }) async {
    final Map<String, dynamic> queryParameters = {'page': page, 'limit': limit};
    if (year != null) queryParameters['year'] = year;
    final response = await apiClient.get(
      '/api/treasury/distributions/history',
      operationName: 'getDistributionHistory',
      queryParameters: queryParameters,
    );
    final List<dynamic> data = response['data'] ?? [];
    final Map<String, dynamic> meta = response['meta'] ?? {};
    return {
      'items': data
          .map((item) => DistributionHistoryItemModel.fromJson(item))
          .toList(),
      'has_more': meta['has_more'] ?? false,
      'total_records': meta['total_records'] ?? 0,
    };
  }

  Future<LotDetailsDataEntity> lotDetails(String batchId) async {
    final response = await apiClient.get(
      '/api/treasury/batches/$batchId',
      operationName: 'lotDetails',
    );
    return LotDetailsDataModel.fromJson(response['data']);
  }

  Future<PayTheFeeResponseModel> payTheFee(
    PayTheFeeRequestModel payTheFeeRequest,
    String idLoan,
    String idQuota,
  ) async {
    final response = await apiClient.postFormData(
      '/api/treasury/corporate-loans/$idLoan/quotas/$idQuota/pay',
      data: payTheFeeRequest.toFormDataMap(),
      operationName: 'payTheFee',
      files: [
        {
          'name': 'comprobante',
          'path': payTheFeeRequest.comprobante,
          'filename': payTheFeeRequest.comprobante.split('/').last,
        },
      ],
    );

    return PayTheFeeResponseModel.fromJson(response['data']);
  }
    Future<NewLayoutResponseEntity> newLayoutPost(
    String monthPeriod,
    String yearPeriod,
    double baseAmount,
  ) async {
    final response = await apiClient.post(
      '/api/treasury/distributions',
      data: {
        "month_period": monthPeriod,
        "year_period": yearPeriod,
        "base_amount": baseAmount,
      },
      operationName: 'newLayoutPost',
    );
    return NewLayoutResponseModel.fromJson(response['data']);
  }
  Future<SimulateDistributionResponseEntity> postSimulateDistribution(
    double baseAmount,
  ) async {
    final response = await apiClient.post(
      '/api/treasury/distributions/simulate',
      data: {
        "base_amount": baseAmount,
      },
      operationName: 'postSimulateDistribution',
    );
    return SimulateDistributionResponseModel.fromJson(response);
  }

  Future<Map<String, dynamic>> getContributionDetail(
    String contributionId, {
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, dynamic> queryParameters = {'page': page, 'limit': limit};
    final response = await apiClient.get(
      '/api/treasury/contributions/$contributionId',
      operationName: 'getContributionDetail',
      queryParameters: queryParameters,
    );
    final Map<String, dynamic> headerMetrics =
        response['header_metrics'] as Map<String, dynamic>;
    final List<dynamic> membersList = response['members_list'] ?? [];
    final Map<String, dynamic> meta = response['meta'] ?? {};
    return {
      'header_metrics': ContributionDetailHeaderMetricsModel.fromJson(
        headerMetrics,
      ),
      'members_list': membersList
          .map(
            (m) => ContributionDetailMemberModel.fromJson(
              m as Map<String, dynamic>,
            ),
          )
          .toList(),
      'has_more': meta['has_more'] ?? false,
      'total_records': meta['total_records'] ?? 0,
    };
  }

  Future<Map<String, dynamic>> getContributionReceipts(
    String contributionId, {
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, dynamic> queryParameters = {'page': page, 'limit': limit};
    final response = await apiClient.get(
      '/api/treasury/contributions/$contributionId/receipts',
      operationName: 'getContributionReceipts',
      queryParameters: queryParameters,
    );
    final List<dynamic> data = response['data'] ?? [];
    final Map<String, dynamic> meta = response['meta'] ?? {};
    return {
      'receipts': data
          .map((r) => ContributionReceiptModel.fromJson(r as Map<String, dynamic>))
          .toList(),
      'has_more': meta['has_more'] ?? false,
      'total_records': meta['total_records'] ?? 0,
    };
  }

  Future<Map<String, dynamic>> getContributions({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final Map<String, dynamic> queryParameters = {'page': page, 'limit': limit};
    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }
    final response = await apiClient.get(
      '/api/treasury/contributions',
      operationName: 'getContributions',
      queryParameters: queryParameters,
    );
    final List<dynamic> data = response['data'] ?? [];
    final Map<String, dynamic> meta = response['meta'] ?? {};
    final Map<String, dynamic> metrics = response['metrics'] ?? {};
    return {
      'items': data.map((item) => ContributeItemModel.fromJson(item)).toList(),
      'metrics': ContributeMetricsModel.fromJson(metrics),
      'has_more': meta['has_more'] ?? false,
      'total_records': meta['total_records'] ?? 0,
    };
  }
  Future<ReceiptResponseEneity> receiptDetails(String receiptId) async {
    final response = await apiClient.get(
      '/api/treasury/distributions/receipt/$receiptId',
      operationName: 'receiptDetails',
    );
    return ReceiptResponseModel.fromJson(response['data']);
  }
  Future<ContributionPaymentReceiptModel> getContributionPaymentReceipt(
    String transactionId,
  ) async {
    final response = await apiClient.get(
      '/api/treasury/contributions/receipt/$transactionId',
      operationName: 'getContributionPaymentReceipt',
    );
    return ContributionPaymentReceiptModel.fromJson(response['data']);
  }

  Future<RecordContributionPaymentDataModel> recordContributionPayment(
    RecordContributionPaymentRequestModel recordContributionPaymentRequestModel
  ) async {
    final response = await apiClient.postFormData(
      '/api/treasury/contributions/pay',
      data: recordContributionPaymentRequestModel.toFormDataMap(),
      operationName: 'recordContributionPayment',
      files: [
        {
          'name': 'evidencia',
          'path': recordContributionPaymentRequestModel.evidencia,
          'filename': recordContributionPaymentRequestModel.evidencia.split('/').last,
        },
      ],
    );

    return RecordContributionPaymentDataModel.fromJson(response['data']);
  }
}
