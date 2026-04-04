import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/modules/treasury/domain/entity/income_request_entity.dart';
import 'package:front_gestion_minera/utils/error.dart';
import '../../../../core/networking/base_api_exception.dart';
import '../../domain/entity/entity.dart';
import '../../domain/repositories/treasury_repository.dart';

part 'treasury_event.dart';
part 'treasury_state.dart';

class TreasuryBloc extends Bloc<TreasuryEvent, TreasuryState> {
  int _currentPage = 1;
  bool _hasReachedMax = false;
  int _currentTotalRecords = 0;
  List<ListOfPendingDataEntity> _items = [];
  List<InternalLoansEntity> _itemsLoans = [];

  final TreasuryRepository repository;

  List<CashRegisterEntity> cashRegisters = [];

  //onventario
  int _currentBatchPage = 1;
  bool _hasReachedBatchMax = false;
  List<GoldBatchEntity> _goldBatches = [];
  GoldInventoryEntity? _goldInventory;
  //Evitar bombardeo a la api
  bool _isLoadingMoreBatches = false;
  bool _isLoadingMorePending = false;
  bool _isLoadingMorePayment = false;

  // Variables dedicadas para préstamos internos (evitan colisión con pending)
  int _currentLoansPage = 1;
  bool _hasReachedLoansMax = false;
  int _currentLoansTotalRecords = 0;
  bool _isLoadingMoreLoans = false;

  String? _currentStatus;
  String? _currentSearch;
  //
  int _paymentHistoryPage = 1;
  bool _paymentHistoryReachedMax = false;
  int _paymentHistoryTotalRecords = 0;
  List<PaymentHistoryItemEntity> _paymentHistoryItems = [];
  PaymentHistorySummaryEntity? _paymentHistorySummary;
  String? _currentBatchStatus;

  TreasuryBloc({required this.repository}) : super(TreasuryInitial()) {
    on<FetchTreasuryMetricsEvent>(_onFetchTreasuryMetrics);
    on<DashboardDataEvent>(_dashboardData);
    on<DetailsofanapplicationEvent>(_getDetailsofanapplication);
    on<LoadMorePendingEvent>(_loadMorePendingRequests);
    on<ListOfPendingRequestsEvent>(_listOfPending);

    on<GetFinancialReportEvent>(_onGetFinancialReportEvent);
    on<RegisterUrgentIncomeEvent>(_onRegisterUrgentIncome);
    on<GetCashRegistersEvent>(_onGetCashRegisters);
    on<ConfirmPaymentEvent>(_onConfirmPayment);
    on<RejectAnApplicationEvent>(_rejectAnApplication);
    on<RegisterUrgentExpenseEvent>(_onRegisterUrgentExpense);
    on<FetchGoldDashboardDataEvent>(_onFetchGoldDashboardData);
    on<LoadMoreGoldBatchesEvent>(_onLoadMoreGoldBatches);
    on<GetPaymentHistoryEvent>(_onGetPaymentHistory);
    on<LoadMorePaymentHistoryEvent>(_onLoadMorePaymentHistory);
    on<InternalLoansRequestsEvent>(_onFechInternalLoans);
    on<InternalLoansEvent>(_onLoadMoreInternalLoans);
    on<TransactionDetailsEvent>(_onTransactionDetails);
    on<NewExtractionEvent>(_onNewExtraction);
    on<PreviewSaleEvent>(_onPreviewSale);
    on<RegisterSaleEvent>(_onRegisterSale);
    on<ApplyForALoanEvent>(_onApplyForALoan);
    on<NewLoansSimulateEvent>(_onNewLoansSimulate);
    on<LoanDetailsEvent>(_onLoanDetails);
    on<PayTheFeeEvent>(_onPayTheFee);
  }

  Future<void> _onFetchTreasuryMetrics(
    FetchTreasuryMetricsEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    emit(TreasuryMetricsLoading());
    try {
      final metrics = await repository.getMetrics();
      emit(TreasuryMetricsLoaded(metrics: metrics));
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(TreasuryMetricsError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(TreasuryMetricsError('Error inesperado: $e'));
    }
  }

  Future<void> _dashboardData(
    DashboardDataEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    emit(DashboardDataLoading());
    try {
      final responseBalance = await repository.getBondBalence();
      final responsePending = await repository.getPendingApplications();
      emit(
        DashboardDataLoaded(
          bondBalance: responseBalance,
          pendingApplicationsResponseEntity: responsePending,
        ),
      );
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(DashboardDataError(message: mapErrorMessage(error.key)));
    } catch (e) {
      emit(DashboardDataError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _getDetailsofanapplication(
    DetailsofanapplicationEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    emit(DetailsofanapplicationLoading());
    try {
      final response = await repository.getDetailsofanapplication(event.id);
      final responseCash = await repository.getCash();
      emit(
        DetailsofanapplicationSuccess(data: response.data, cash: responseCash),
      );
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(DetailsofanapplicationError(message: mapErrorMessage(error.key)));
    } catch (e) {
      emit(DetailsofanapplicationError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _listOfPending(
    ListOfPendingRequestsEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    if (!event.isRefresh && _items.isNotEmpty) {
      emit(
        ListOfPendingRequestsSuccess(
          list: List.from(_items),
          hasReachedMax: _hasReachedMax,
          totalRecords: _currentTotalRecords,
        ),
      );
      return;
    }

    if (event.isRefresh) {
      _currentPage = 1;
      _hasReachedMax = false;
      _items.clear();
      emit(ListOfPendingRequestsLoading());
    }

    try {
      final response = await repository.listOfPendingRequests(
        page: _currentPage,
      );
      _items = response.items;
      _hasReachedMax = !response.hasMoreData;
      _currentTotalRecords = response.totalRecords;
      emit(
        ListOfPendingRequestsSuccess(
          list: List.from(_items),
          hasReachedMax: _hasReachedMax,
          totalRecords: _currentTotalRecords,
        ),
      );
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(ListOfPendingRequestsError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(ListOfPendingRequestsError('Error inesperado: $e'));
    }
  }

  Future<void> _loadMorePendingRequests(
    LoadMorePendingEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    if (_hasReachedMax || _isLoadingMorePending) return;
    _isLoadingMorePending = true;
    _currentPage++;
    try {
      final response = await repository.listOfPendingRequests(
        page: _currentPage,
      );

      _items.addAll(response.items);

      _hasReachedMax = !response.hasMoreData;
      emit(
        ListOfPendingRequestsSuccess(
          list: _items,
          hasReachedMax: _hasReachedMax,
          totalRecords: _currentTotalRecords,
        ),
      );
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      _currentPage--;
      emit(ListOfPendingRequestsError(mapErrorMessage(error.key)));
    } catch (e) {
      _currentPage--;
      emit(ListOfPendingRequestsError('Error inesperado: $e'));
    } finally {
      _isLoadingMorePending = false;
    }
  }

  Future<void> _onGetFinancialReportEvent(
    GetFinancialReportEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    emit(FinancialReportLoading());

    try {
      final report = await repository.getFinancialReport(
        period: event.period,
        exactDate: event.exactDate,
      );

      emit(FinancialReportLoaded(report: report));
    } catch (e) {
      emit(FinancialReportError(message: 'Error al cargar el reporte: $e'));
    }
  }

  Future<void> _onRegisterUrgentIncome(
    RegisterUrgentIncomeEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    emit(UrgentIncomeLoading());
    try {
      final response = await repository.registerUrgentIncome(event.request);
      emit(UrgentIncomeSuccess(response: response));
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(UrgentExpenseError(message: mapErrorMessage(error.key)));
    } catch (e) {
      emit(UrgentIncomeError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onRegisterUrgentExpense(
    RegisterUrgentExpenseEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    emit(UrgentExpenseLoading());
    try {
      final response = await repository.registerUrgentExpense(event.request);
      emit(UrgentExpenseSuccess(response: response));
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(UrgentExpenseError(message: error.message));
    } catch (e) {
      emit(UrgentExpenseError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onGetCashRegisters(
    GetCashRegistersEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    emit(CashRegistersLoading());
    try {
      final registers = await repository.getCashRegisters();
      cashRegisters = registers;
      emit(CashRegistersLoaded(cashRegisters: registers));
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(CashRegistersError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(CashRegistersError('Error inesperado: $e'));
    }
  }

  Future<void> _onConfirmPayment(
    ConfirmPaymentEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    emit(ConfirmPaymentLoading());
    try {
      final response = await repository.confirmPayment(
        event.idRequest,
        event.confirmPaymentRequets,
      );
      emit(ConfirmPaymentLoaded(confirmPayment: response));
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(ConfirmPaymentError(message: error.message));
    } catch (e) {
      emit(ConfirmPaymentError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _rejectAnApplication(
    RejectAnApplicationEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    emit(RejectAnApplicationLoading());
    try {
      final response = await repository.rejectAnApplication(
        event.idCash,
        event.reason,
      );
      emit(RejectAnApplicationLoaded(data: response));
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(RejectAnApplicationError(message: mapErrorMessage(error.key)));
    } catch (e) {
      emit(RejectAnApplicationError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onGetPaymentHistory(
    GetPaymentHistoryEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    if (!event.isRefresh && _paymentHistoryItems.isNotEmpty) {
      emit(
        PaymentHistoryLoaded(
          summary: _paymentHistorySummary!,
          items: List.from(_paymentHistoryItems),
          hasReachedMax: _paymentHistoryReachedMax,
          totalRecords: _paymentHistoryTotalRecords,
        ),
      );
      return;
    }

    if (event.isRefresh) {
      _paymentHistoryPage = 1;
      _paymentHistoryReachedMax = false;
      _paymentHistoryItems.clear();
      _paymentHistorySummary = null;
      emit(PaymentHistoryLoading());
    }

    try {
      final response = await repository.getPaymentHistory(
        page: _paymentHistoryPage,
      );
      _paymentHistoryItems = response.items;
      _paymentHistorySummary = response.summary;
      _paymentHistoryReachedMax = !response.hasMoreData;
      _paymentHistoryTotalRecords = response.totalRecords;
      emit(
        PaymentHistoryLoaded(
          summary: response.summary,
          items: List.from(_paymentHistoryItems),
          hasReachedMax: _paymentHistoryReachedMax,
          totalRecords: _paymentHistoryTotalRecords,
        ),
      );
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(PaymentHistoryError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(PaymentHistoryError('Error inesperado: $e'));
    }
  }

  Future<void> _onLoadMorePaymentHistory(
    LoadMorePaymentHistoryEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    if (_paymentHistoryReachedMax || _isLoadingMorePayment) return;
    _isLoadingMorePayment = true;
    _paymentHistoryPage++;
    try {
      final response = await repository.getPaymentHistory(
        page: _paymentHistoryPage,
      );
      _paymentHistoryItems.addAll(response.items);
      _paymentHistoryReachedMax = !response.hasMoreData;
      emit(
        PaymentHistoryLoaded(
          summary: _paymentHistorySummary!,
          items: List.from(_paymentHistoryItems),
          hasReachedMax: _paymentHistoryReachedMax,
          totalRecords: _paymentHistoryTotalRecords,
        ),
      );
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      _paymentHistoryPage--;
      emit(PaymentHistoryError(mapErrorMessage(error.key)));
    } catch (e) {
      _paymentHistoryPage--;
      emit(PaymentHistoryError('Error inesperado: $e'));
    } finally {
      _isLoadingMorePayment = false;
    }
  }

  Future<void> _onFetchGoldDashboardData(
    FetchGoldDashboardDataEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    if (event.isRefresh) {
      _currentBatchPage = 1;
      _hasReachedBatchMax = false;
      _isLoadingMoreBatches = false;
      _goldBatches.clear();
      _currentBatchStatus = event.status;
      emit(GoldDashboardLoading());
    }

    try {
      final responses = await Future.wait([
        repository.getGoldInventory(),
        repository.getGoldBatches(
          page: _currentBatchPage,
          status: _currentBatchStatus,
        ),
      ]);

      _goldInventory = responses[0] as GoldInventoryEntity;
      final batchesData = responses[1] as PaginatedGoldBatchesEntity;

      _goldBatches = batchesData.batches;
      _hasReachedBatchMax = !batchesData.hasMore;

      emit(
        GoldDashboardLoaded(
          inventory: _goldInventory!,
          batches: List.from(_goldBatches),
          hasReachedMax: _hasReachedBatchMax,
        ),
      );
    } on BaseApiException catch (error) {
      emit(GoldDashboardError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(GoldDashboardError('Error inesperado: $e'));
    }
  }

  Future<void> _onLoadMoreGoldBatches(
    LoadMoreGoldBatchesEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    if (_hasReachedBatchMax ||
        _goldInventory == null ||
        _isLoadingMoreBatches) {
      return;
    }
    _isLoadingMoreBatches = true;
    _currentBatchPage++;

    try {
      final response = await repository.getGoldBatches(
        page: _currentBatchPage,
        status: _currentBatchStatus,
      );
      _goldBatches.addAll(response.batches);
      _hasReachedBatchMax = !response.hasMore;

      emit(
        GoldDashboardLoaded(
          inventory: _goldInventory!,
          batches: List.from(_goldBatches),
          hasReachedMax: _hasReachedBatchMax,
        ),
      );
    } on BaseApiException catch (error) {
      _currentBatchPage--;
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(GoldDashboardError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(GoldDashboardError('Error inesperado: $e'));
    } finally {
      _isLoadingMoreBatches = false;
    }
  }

  Future<void> _onFechInternalLoans(
    InternalLoansRequestsEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    _currentLoansPage = 1;
    _hasReachedLoansMax = false;
    _itemsLoans.clear();
    _currentStatus = event.status;
    _currentSearch = event.search;
    emit(InternalLoansLoading());
    try {
      final response = await repository.getInternalLoans(
        page: _currentLoansPage,
        status: _currentStatus,
        search: _currentSearch,
      );
      _itemsLoans = response.items;
      _hasReachedLoansMax = !response.hasMore;
      _currentLoansTotalRecords = response.totalRecords;
      emit(
        InternalLoansLoaded(
          list: List.from(_itemsLoans),
          hasReachedMax: _hasReachedLoansMax,
          totalRecords: _currentLoansTotalRecords,
        ),
      );
    } on BaseApiException catch (error) {
      emit(InternalLoansError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(InternalLoansError('Error inesperado: $e'));
    }
  }

  Future<void> _onLoadMoreInternalLoans(
    InternalLoansEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    if (_hasReachedLoansMax || _isLoadingMoreLoans) return;
    _isLoadingMoreLoans = true;
    _currentLoansPage++;
    try {
      final response = await repository.getInternalLoans(
        status: _currentStatus,
        search: _currentSearch,
        page: _currentLoansPage,
      );
      _itemsLoans.addAll(response.items);
      _hasReachedLoansMax = !response.hasMore;
      emit(
        InternalLoansLoaded(
          list: List.from(_itemsLoans),
          hasReachedMax: _hasReachedLoansMax,
          totalRecords: _currentLoansTotalRecords,
        ),
      );
    } on BaseApiException catch (error) {
      _currentLoansPage--;
      emit(InternalLoansError(mapErrorMessage(error.key)));
    } catch (e) {
      _currentLoansPage--;
      emit(InternalLoansError('Error inesperado: $e'));
    } finally {
      _isLoadingMoreLoans = false;
    }
  }

  Future<void> _onTransactionDetails(
    TransactionDetailsEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    emit(TransactionDetailsLoading());
    try {
      final response = await repository.getTransactionDetails(
        event.idTransaction,
      );
      emit(TransactionDetailsLoaded(transactionDetails: response));
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(TransactionDetailsError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(TransactionDetailsError('Error inesperado: $e'));
    }
  }

  Future<void> _onNewExtraction(
    NewExtractionEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    emit(NewExtractionLoading());
    try {
      final response = await repository.newExtraction(
        event.newExtractionRequets,
      );
      emit(NewExtractionLoaded(newExtraction: response));
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(NewExtractionError(message: error.message));
    } catch (e) {
      emit(NewExtractionError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onPreviewSale(
    PreviewSaleEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    emit(SalePreviewLoading());
    try {
      final response = await repository.previewSale(event.gramsToSell);
      emit(SalePreviewLoaded(preview: response));
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(SalePreviewError(message: mapErrorMessage(error.key)));
    } catch (e) {
      emit(SalePreviewError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onRegisterSale(
    RegisterSaleEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    emit(RegisterSaleLoading());
    try {
      final response = await repository.registerSale(event.request);
      emit(RegisterSaleLoaded(sale: response));
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(RegisterSaleError(message: mapErrorMessage(error.key)));
    } catch (e) {
      emit(RegisterSaleError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onNewLoansSimulate(
    NewLoansSimulateEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    emit(NewLoansSimulateLoading());
    try {
      final response = await repository.postNewLoansSimulate(
        event.amount,
        event.termMonths,
        event.annualInterestRate,
        event.startDate,
      );
      final responseCash = await repository.getCash();
      emit(NewLoansSimulateLoaded(loan: response, cash: responseCash));
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(NewLoansSimulateError(message: mapErrorMessage(error.key)));
    } catch (e) {
      emit(NewLoansSimulateError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onApplyForALoan(
    ApplyForALoanEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    emit(ApplyForALoanLoading());
    try {
      final response = await repository.applyForALoan(
        event.lenderName,
        event.amount,
        event.termMonths,
        event.annualInterestRate,
        event.startDate,
        event.cajaDestinoId,
      );
      emit(ApplyForALoanLoaded(loan: response));
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(ApplyForALoanError(message: mapErrorMessage(error.key)));
    } catch (e) {
      emit(ApplyForALoanError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onLoanDetails(
    LoanDetailsEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    emit(LoanDetailsLoading());
    try {
      final response = await repository.getloanDatails(event.idLoan);
      final responseCash = await repository.getCash();
      emit(LoanDetailsLoaded(loanDetails: response, cash: responseCash));
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(LoanDetailsError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(LoanDetailsError('Error inesperado: $e'));
    }
  }

  Future<void> _onPayTheFee(
    PayTheFeeEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    emit(PayTheFeeLoading());
    try {
      final response = await repository.payTheFee(
        event.payTheFeeRequest,
        event.idLoan,
        event.idQuota,
      );
      emit(PayTheFeeLoaded(payTheFee: response));
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(PayTheFeeError(message: error.message));
    } catch (e) {
      emit(PayTheFeeError(message: 'Error inesperado: $e'));
    }
  }
}
