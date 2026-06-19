import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/networking/base_api_exception.dart';
import 'package:front_gestion_minera/utils/error.dart';
import 'package:front_gestion_minera/modules/partners/domain/entity/money_request_entity.dart';
import 'package:front_gestion_minera/modules/partners/domain/entity/request_history_entity.dart';

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
  final MemberInboxRepository memberInboxRepository;
  
  bool _isLoadingMore = false;
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

  // Paginación para préstamos del socio (Loans)
  int _loanPage = 1;
  bool _loanReachedMax = false;
  bool _loanLoadingMore = false;
  List<LoanHistoryDataEntity> _currentLoanHistory = [];
  LoanMetricsEntity? _currentLoanMetrics;
  String? _loanStatus;
  String? _loanSearch;
  String? _loanPeriod;
  String? _loanExactDate;

  PartnersBloc({
    required this.repository,
    required this.moneyRepository,
    required this.loanHistoryRepository,
    required this.loanRegisterRequestRepository,
    required this.distributesRepository,
    required this.memberInboxRepository,
  }) : super(ContributeDataInitial()) {
    on<FetchContributeDataEvent>(_onFetchContributeData);

    on<PartnersSubmitMoneyRequestEvent>(_onSubmitMoneyRequest);
    on<GetHistoryEvent>(_onGetRequestHistory);
    on<LoadMoreRequestHistoryEvent>(_onLoadMoreHistory);

    on<LoanHistoryFetchEvent>(_onLoanHistoryFetch);
    on<LoanHistoryLoadMoreEvent>(_onLoanHistoryLoadMore);
    on<LoanDetailFetchEvent>(_onLoanDetailFetch);

    on<LoanRegisterEvent>(_onLoanRegister);

    //Dividendos
    on<FetchDistributesDataEvent>(_onFetchDistributesData);
    on<LoadMoreDistributesEvent>(_onLoadMoreDistributes);

    //Bandeja de socios
    on<MemberInboxRequestEvent>(_onMemberInboxRequest);
  }

  Future<void> _onMemberInboxRequest(
    MemberInboxRequestEvent event,
    Emitter<PartnersState> emit,
  ) async {
    emit(MemberInboxLoading());
    try {
      final items = await memberInboxRepository.getInbox();
      emit(MemberInboxLoaded(items));
    } on BaseApiException catch (error) {
      emit(MemberInboxError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(MemberInboxError('Error inesperado: $e'));
    }
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

         for (final item in history) {
          late final String groupKey;

          if (item.fechaPago != null) {
            final monthName = months[item.fechaPago!.month - 1];
            groupKey = '$monthName ${item.fechaPago!.year}';
          } else {
            groupKey = 'PENDIENTES';
          }

          groupedHistory.putIfAbsent(groupKey, () => []);
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
    if (_hasReachedMax || _isLoadingMore) return;
    _isLoadingMore = true;
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
    } on BaseApiException catch 
    (error) {
      emit(RequestHistoryError(mapErrorMessage(error.key)));
    } catch (e) {
      _currentPage--;
      emit(RequestHistoryError('Error inesperado: $e'));
    } finally {
     _isLoadingMore = false;
    }
  }

  Future<void> _onLoanHistoryFetch(
    LoanHistoryFetchEvent event,
    Emitter<PartnersState> emit,
  ) async {
    // Guardamos los filtros activos para la paginación.
    _loanStatus = event.status;
    _loanSearch = event.search;
    _loanPeriod = event.period;
    _loanExactDate = event.exactDate;
    _loanPage = 1;
    _loanReachedMax = false;
    _loanLoadingMore = false;

    emit(LoanHistoryLoading());
    try {
      final metrics = await loanHistoryRepository.getMetrics(
        period: event.period,
        exactDate: event.exactDate,
      );
      final page = await loanHistoryRepository.getHistory(
        status: event.status,
        search: event.search,
        period: event.period,
        exactDate: event.exactDate,
        page: 1,
        limit: 10,
      );

      _currentLoanMetrics = metrics;
      _currentLoanHistory = page.items;
      _loanReachedMax = !page.hasMore;

      emit(LoanHistoryLoaded(
        metrics: metrics,
        items: List.of(_currentLoanHistory),
        hasReachedMax: _loanReachedMax,
      ));
    } on BaseApiException catch (error) {
      emit(LoanHistoryError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(LoanHistoryError('Error inesperado: $e'));
    }
  }

  Future<void> _onLoanHistoryLoadMore(
    LoanHistoryLoadMoreEvent event,
    Emitter<PartnersState> emit,
  ) async {
    if (_loanLoadingMore || _loanReachedMax) return;
    if (_currentLoanMetrics == null) return;
    _loanLoadingMore = true;

    try {
      final nextPage = _loanPage + 1;
      final page = await loanHistoryRepository.getHistory(
        status: _loanStatus,
        search: _loanSearch,
        period: _loanPeriod,
        exactDate: _loanExactDate,
        page: nextPage,
        limit: 10,
      );

      _loanPage = nextPage;
      _currentLoanHistory = [..._currentLoanHistory, ...page.items];
      _loanReachedMax = !page.hasMore;

      emit(LoanHistoryLoaded(
        metrics: _currentLoanMetrics!,
        items: List.of(_currentLoanHistory),
        hasReachedMax: _loanReachedMax,
      ));
    } catch (_) {
      // Silencioso: mantenemos lo ya cargado si falla el "cargar más".
    } finally {
      _loanLoadingMore = false;
    }
  }

  Future<void> _onLoanDetailFetch(
    LoanDetailFetchEvent event,
    Emitter<PartnersState> emit,
  ) async {
    emit(LoanDetailLoading());
    try {
      final detail = await loanHistoryRepository.getDetail(event.loanId);
      emit(LoanDetailLoaded(detail));
    } on BaseApiException catch (error) {
      emit(LoanDetailError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(LoanDetailError('Error inesperado: $e'));
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
        hasInterest: event.hasInterest,
        interestRate: event.interestRate,
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
    if (_distributesReachedMax || _currentDistributesMetrics == null || _isLoadingMore) return;
    _isLoadingMore = true;
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
    } on BaseApiException catch (error) {
      emit(DistributesDataError(mapErrorMessage(error.key)));
    } catch (e) {
      _distributesPage--;
      emit(DistributesDataError('Error inesperado: $e'));
    } finally {
     _isLoadingMore = false;
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
