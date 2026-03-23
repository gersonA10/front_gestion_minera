import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/modules/treasury/data/models/model.dart';
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

  final TreasuryRepository repository;

  List<CashRegisterEntity> cashRegisters = [];

  TreasuryBloc({required this.repository}) : super(TreasuryInitial()) {
    on<FetchTreasuryMetricsEvent>(_onFetchTreasuryMetrics);
    on<DashboardDataEvent>(_dashboardData);
    on<DetailsofanapplicationEvent>(_getDetailsofanapplication);
    on<LoadMorePendingEvent>(_loadMorePendingRequests);
    on<ListOfPendingRequestsEvent>(_listOfPending);

    on<GetFinancialReportEvent>(_onGetFinancialReportEvent);
    on<RegisterUrgentIncomeEvent>(_onRegisterUrgentIncome);
    on<GetCashRegistersEvent>(_onGetCashRegisters);
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
      emit(DetailsofanapplicationSuccess(data: response.data, cash: responseCash));
    } on BaseApiException catch (error) {
      emit(DetailsofanapplicationError(message:  mapErrorMessage(error.key)));
    } catch (e) {
      emit(DetailsofanapplicationError(message:  'Error inesperado: $e'));
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
      final response = await repository.listOfPendingRequests(page: _currentPage);
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
      emit(ListOfPendingRequestsError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(ListOfPendingRequestsError('Error inesperado: $e'));
    }
  }

   Future<void> _loadMorePendingRequests(
    LoadMorePendingEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    if (_hasReachedMax) return;
    _currentPage++;
    try {
      final response = await repository.listOfPendingRequests(page: _currentPage);

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
      emit(ListOfPendingRequestsError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(ListOfPendingRequestsError('Error inesperado: $e'));
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
      emit(NetworkError(message: mapErrorMessage(error.key)));
    } catch (e) {
      emit(UrgentIncomeError(message: 'Error inesperado: $e'));
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
      emit(CashRegistersError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(CashRegistersError('Error inesperado: $e'));
    }
  }
}
