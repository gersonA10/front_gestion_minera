import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/networking/base_api_exception.dart';
import 'package:front_gestion_minera/utils/error.dart';
import 'package:front_gestion_minera/modules/partners/domain/entity/money_request_entity.dart';
import 'package:front_gestion_minera/modules/partners/domain/entity/request_history_entity.dart';
import 'package:front_gestion_minera/modules/partners/domain/repositories/money_request_repository.dart';

import '../../domain/entity/entity.dart';
import '../../domain/repositories/repository.dart';
part 'partners_event.dart';
part 'partners_state.dart';

class PartnersBloc extends Bloc<PartnersEvent, PartnersState> {
  PartnersRepository repository;
  final MoneyRequestRepository moneyRepository;
  final LoanHistoryRepository loanHistoryRepository;
  final LoanRegisterRequestRepository loanRegisterRequestRepository;
  final DistributesRepository distributesRepository; 

  int _currentPage = 1;
  bool _hasReachedMax = false;
  List<RequestHistoryEntity> _currentHistory = [];
  String? _currentStatus;
  String? _currentSearch;

  // Paginación para dividendos (Distributes)
  int _distributesPage = 1;
  bool _distributesReachedMax = false;
  List<DistributesHistoryEntity> _currentDistributesHistory = [];
  DistributesMetricsEntity? _currentDistributesMetrics;
  String? _distStatus;
  String? _distSearch;
  String? _distPeriod;
  String? _distExactDate;

  PartnersBloc({
    required this.repository,
    required this.moneyRepository,
    required this.loanHistoryRepository,
    required this.loanRegisterRequestRepository,
    required this.distributesRepository,
  }) : super(ContributeDataInitial()) {
    on<FetchContributeDataEvent>(_onFetchContributeData);

    on<PartnersSubmitMoneyRequestEvent>(_onSubmitMoneyRequest);
    on<GetHistoryEvent>(_onGetRequestHistory);
    on<LoadMoreRequestHistoryEvent>(_onLoadMoreHistory);

    on<LoanHistoryRequestEvent>(_onLoanHistoryRequest);
    on<LoanHistoryStatustEvent>(_onLoanHistoryStatusRequest);
    on<LoanHistorySearchEvent>(_onLoanHistorySearchRequest);

    on<LoanRegisterEvent>(_onLoanRegister);

    //Dividendos
    on<FetchDistributesDataEvent>(_onFetchDistributesData);
    on<LoadMoreDistributesEvent>(_onLoadMoreDistributes);
  }

  Future<void> _onFetchContributeData(
    FetchContributeDataEvent event,
    Emitter<PartnersState> emit,
  ) async {
    emit(ContributeDataLoading());
    try {
      // Disparamos ambas peticiones en paralelo
      final results = await Future.wait([
        repository.getContributionMetrics(),
        repository.getContributeHistory(
          status: event.status,
          search: event.search,
          period: event.period,
          exactDate: event.exactDate,
        ),
      ]);

      final metrics = results[0] as ContributionMetricsEntity;
      final history = results[1] as List<ContributeHistoryDataEntity>;

      // Agrupamos el historial por "MES AÑO"
      final Map<String, List<ContributeHistoryDataEntity>> groupedHistory = {};
      const months = [
        'ENERO',
        'FEBRERO',
        'MARZO',
        'ABRIL',
        'MAYO',
        'JUNIO',
        'JULIO',
        'AGOSTO',
        'SEPTIEMBRE',
        'OCTUBRE',
        'NOVIEMBRE',
        'DICIEMBRE',
      ];

      for (var item in history) {
        final monthName = months[item.fechaPago.month - 1];
        final groupKey = '$monthName ${item.fechaPago.year}';

        if (!groupedHistory.containsKey(groupKey)) {
          groupedHistory[groupKey] = [];
        }
        groupedHistory[groupKey]!.add(item);
      }

      emit(
        ContributeDataLoaded(metrics: metrics, groupedHistory: groupedHistory),
      );
    } on BaseApiException catch (error) {
      emit(ContributeDataError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(ContributeDataError('Error inesperado: $e'));
    }
  }

  Future<void> _onSubmitMoneyRequest(
    PartnersSubmitMoneyRequestEvent event,
    Emitter<PartnersState> emit,
  ) async {
    emit(PartnersMoneyRequestLoading());
    try {
      if (event.evidenceUrlPath.isEmpty) {
        emit(PartnersMoneyRequestError('El Comprobante es obligatorio.'));
        return;
      }

      final requestEntity = MoneyRequestEntity(
        area: event.area,
        requestedAmount: event.requestedAmount,
        description: event.description,
        evidenceUrlPath: event.evidenceUrlPath,
      );

      await moneyRepository.submitMoneyRequest(requestEntity);

      emit(PartnersMoneyRequestSuccess());
    } on BaseApiException catch (error) {
      switch (error.key) {
        case "dio_unexpected":
        case "dio_connect_timeout":
          emit(
            PartnersMoneyRequestError(
              'Ocurrió un error al enviar la solicitud de egreso.',
            ),
          );
          break;
        default:
          emit(
            PartnersMoneyRequestError(
              'Ocurrió un error al enviar la solicitud de egreso.',
            ),
          );
      }
    }
  }

  Future<void> _onGetRequestHistory(
    GetHistoryEvent event,
    Emitter<PartnersState> emit,
  ) async {
    if (event.isRefresh) {
      _currentPage = 1;
      _hasReachedMax = false;
      _currentHistory.clear();
      emit(RequestHistoryLoading());
    }

    _currentStatus = event.status;
    _currentSearch = event.search;

    try {
      final paginatedData = await moneyRepository.getHistory(
        status: _currentStatus,
        search: _currentSearch,
        page: _currentPage,
      );

      _currentHistory = paginatedData.items;
      _hasReachedMax = !paginatedData.hasMoreData;

      emit(
        RequestHistoryLoaded(
          history: List.from(_currentHistory),
          hasReachedMax: _hasReachedMax,
        ),
      );
    } on BaseApiException catch (_) {
      emit(RequestHistoryError('Ocurrió un error al cargar el historial.'));
    } catch (e) {
      emit(RequestHistoryError('Error inesperado al cargar datos.'));
    }
  }

  Future<void> _onLoadMoreHistory(
    LoadMoreRequestHistoryEvent event,
    Emitter<PartnersState> emit,
  ) async {
    if (_hasReachedMax || state is! RequestHistoryLoaded) return;

    _currentPage++;
    try {
      final paginatedData = await moneyRepository.getHistory(
        status: _currentStatus,
        search: _currentSearch,
        page: _currentPage,
      );

      _currentHistory.addAll(paginatedData.items);
      _hasReachedMax = !paginatedData.hasMoreData;

      emit(
        RequestHistoryLoaded(
          history: List.from(_currentHistory),
          hasReachedMax: _hasReachedMax,
        ),
      );
    } on BaseApiException catch (_) {
      emit(RequestHistoryError('Ocurrió un error al cargar el historial.'));
    }
  }

  Future<void> _onLoanHistoryRequest(
    LoanHistoryRequestEvent event,
    Emitter<PartnersState> emit,
  ) async {
    emit(LoanHistoryLoading());
    try {
      final response = await loanHistoryRepository.getLoanHistory();
      emit(LoanHistorySuccess(response));
    } on BaseApiException catch (error) {
      emit(LoanHistoryError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(LoanHistoryError('Error inesperado: $e'));
    }
  }

  Future<void> _onLoanHistoryStatusRequest(
    LoanHistoryStatustEvent event,
    Emitter<PartnersState> emit,
  ) async {
    emit(LoanHistoryStatusLoading());
    try {
      final response = await loanHistoryRepository.getLoanHistoryStatus(
        event.status,
      );
      emit(LoanHistoryStatusSuccess(response));
    } on BaseApiException catch (error) {
      emit(LoanHistoryStatusError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(LoanHistoryStatusError('Error inesperado: $e'));
    }
  }

  Future<void> _onLoanHistorySearchRequest(
    LoanHistorySearchEvent event,
    Emitter<PartnersState> emit,
  ) async {
    emit(LoanHistoryStatusLoading());
    try {
      final response = await loanHistoryRepository.getLoanHistoryFillter(
        event.search,
      );
      emit(LoanHistoryStatusSuccess(response));
    } on BaseApiException catch (error) {
      emit(LoanHistoryStatusError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(LoanHistoryStatusError('Error inesperado: $e'));
    }
  }

  Future<void> _onLoanRegister(
    LoanRegisterEvent event,
    Emitter<PartnersState> emit,
  ) async {
    emit(LoanRegisterLoading());
    try {
      if (event.comprobanteImg.isEmpty) {
        emit(LoanRegisterError('El Comprobante es obligatorio.'));
        return;
      }

      final requestEntity = LoanRequestEntity(
        loanType: event.loanType,
        amountOrQuantity: event.amount,
        description: event.description,
        comprobanteImg: event.comprobanteImg,
      );

      await loanRegisterRequestRepository.loanRegister(requestEntity);

      emit(LoanRegisterSuccess());
    } on BaseApiException catch (error) {
      switch (error.key) {
        case "dio_unexpected":
        case "dio_connect_timeout":
          emit(LoanRegisterError('Ocurrió un error al registrar un prestamo.'));
          break;
        default:
          emit(
            LoanRegisterError('Ocurrió un error al registrar un prestamo..'),
          );
      }
    }
  }

  Future<void> _onFetchDistributesData(
    FetchDistributesDataEvent event,
    Emitter<PartnersState> emit,
  ) async {
    if (event.isRefresh) {
      emit(DistributesDataLoading());
      _distributesPage = 1;
      _distributesReachedMax = false;
      _currentDistributesHistory.clear();
    }

    _distStatus = event.status;
    _distSearch = event.search;
    _distPeriod = event.period;
    _distExactDate = event.exactDate;

    try {
      final results = await Future.wait([
        distributesRepository.getMetrics(),
        distributesRepository.getHistory(
          status: _distStatus,
          search: _distSearch,
          period: _distPeriod,
          exactDate: _distExactDate,
          page: _distributesPage,
        ),
      ]);

      _currentDistributesMetrics = results[0] as DistributesMetricsEntity;
      final historyResult = results[1] as PaginatedDistributesHistoryEntity;

      _currentDistributesHistory = historyResult.items;
      _distributesReachedMax = !historyResult.hasMoreData;

      emit(DistributesDataLoaded(
        metrics: _currentDistributesMetrics!,
        groupedHistory: _groupDistributesByMonth(_currentDistributesHistory),
        hasReachedMax: _distributesReachedMax,
      ));
    } on BaseApiException catch (error) {
      emit(DistributesDataError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(DistributesDataError('Error inesperado: $e'));
    }
  }

  Future<void> _onLoadMoreDistributes(
    LoadMoreDistributesEvent event,
    Emitter<PartnersState> emit,
  ) async {
    if (_distributesReachedMax || _currentDistributesMetrics == null) return;

    _distributesPage++;
    try {
      final historyResult = await distributesRepository.getHistory(
        status: _distStatus,
        search: _distSearch,
        period: _distPeriod,
        exactDate: _distExactDate,
        page: _distributesPage,
      );

      _currentDistributesHistory.addAll(historyResult.items);
      _distributesReachedMax = !historyResult.hasMoreData;

      emit(DistributesDataLoaded(
        metrics: _currentDistributesMetrics!,
        groupedHistory: _groupDistributesByMonth(_currentDistributesHistory),
        hasReachedMax: _distributesReachedMax,
      ));
    } on BaseApiException catch (_) {
    }
  }

  Map<String, List<DistributesHistoryEntity>> _groupDistributesByMonth(List<DistributesHistoryEntity> history) {
    final Map<String, List<DistributesHistoryEntity>> grouped = {};
    const months = ['ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO', 'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE'];

    for (var item in history) {
      final monthName = months[item.registeredDate.month - 1];
      final groupKey = '$monthName ${item.registeredDate.year}';

      if (!grouped.containsKey(groupKey)) {
        grouped[groupKey] = [];
      }
      grouped[groupKey]!.add(item);
    }
    return grouped;
  }
}
