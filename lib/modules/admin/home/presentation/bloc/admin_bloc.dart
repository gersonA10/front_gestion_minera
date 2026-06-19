import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/networking/base_api_exception.dart';
import 'package:front_gestion_minera/utils/error.dart';

import '../../domain/entity/entity.dart';
import '../../domain/repositories/repository.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository repository;

  //VARIABLES DE SOLICITUDES PENDIENTES
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasReachedMax = false;
  int _totalRecords = 0;
  List<PendingRequestEntity> _items = [];

  // Variables Historial
  bool _isLoadingMoreHistory = false;
  int _currentHistoryPage = 1;
  bool _hasReachedMaxHistory = false;
  int _totalHistoryRecords = 0;
  String _currentHistoryStatus = 'todos';
  List<RequestHistoryEntity> _historyItems = [];

  //variables historial aportes
  bool _isLoadingMoreContribution = false;
  int _currentContributionPage = 1;
  bool _hasReachedMaxContribution = false;
  int _totalContributionRecords = 0;
  String? _currentContributionPeriod;
  String? _currentContributionExactDate;
  List<ContributionHistoryEntity> _contributionItems = [];

  AdminBloc({required this.repository}) : super(AdminInitial()) {
    on<GetPendingRequestsEvent>(_onGetPendingRequests);
    on<LoadMorePendingRequestsEvent>(_onLoadMore);
    //Historial solicitudes
    on<GetRequestHistoryEvent>(_onGetRequestHistory);
    on<LoadMoreRequestHistoryEvent>(_onLoadMoreHistory);
    //Historial aportes
    on<GetContributionHistoryEvent>(_onGetContributionHistory);
    on<LoadMoreContributionHistoryEvent>(_onLoadMoreContribution);
    on<CreateAdminContributionEvent>(_onCreateContribution);
    on<SimulateAdminContributionEvent>(_onSimulateContribution);
    //detalle solicitud
    on<GetRequestDetailEvent>(_onGetRequestDetail);
    //aprobar o rechazar:
    on<ProcessAdminRequestEvent>(_onProcessRequest);
  }

  Future<void> _onGetPendingRequests(
    GetPendingRequestsEvent event,
    Emitter<AdminState> emit,
  ) async {
    if (event.isRefresh) {
      _currentPage = 1;
      _hasReachedMax = false;
      _items.clear();
      emit(AdminPendingRequestsLoading());
    }

    try {
      final result = await repository.getPendingRequests(page: _currentPage);
      _items = result.items;
      _hasReachedMax = !result.hasMoreData;
      _totalRecords = result.totalRecords;

      emit(
        AdminPendingRequestsLoaded(
          items: List.from(_items),
          hasReachedMax: _hasReachedMax,
          totalRecords: _totalRecords,
        ),
      );
    } on BaseApiException catch (e) {
      emit(AdminPendingRequestsError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(AdminPendingRequestsError('Ocurrió un error inesperado'));
    }
  }

  Future<void> _onLoadMore(
    LoadMorePendingRequestsEvent event,
    Emitter<AdminState> emit,
  ) async {
    if (_hasReachedMax || _isLoadingMore) return;
    _isLoadingMore = true;
    _currentPage++;

    try {
      final result = await repository.getPendingRequests(page: _currentPage);
      _items.addAll(result.items);
      _hasReachedMax = !result.hasMoreData;

      emit(
        AdminPendingRequestsLoaded(
          items: List.from(_items),
          hasReachedMax: _hasReachedMax,
          totalRecords: _totalRecords,
        ),
      );
    } on BaseApiException catch (e) {
      _currentPage--;
      emit(AdminPendingRequestsError(mapErrorMessage(e.key)));
    } catch (_) {
      _currentPage--;
    } finally {
      _isLoadingMore = false;
    }
  }

  //Historial aportes
  Future<void> _onGetContributionHistory(
    GetContributionHistoryEvent event,
    Emitter<AdminState> emit,
  ) async {
    if (event.isRefresh ||
        _currentContributionExactDate != event.exactDate ||
        _currentContributionPeriod != event.period) {
      _currentContributionPage = 1;
      _hasReachedMaxContribution = false;
      _contributionItems.clear();
      _currentContributionExactDate = event.exactDate;
      _currentContributionPeriod = event.period;
      emit(AdminContributionHistoryLoading(_currentContributionExactDate));
    }

    try {
      final result = await repository.getContributesHistory(
        page: _currentContributionPage,
        period: _currentContributionPeriod,
        exactDate: _currentContributionExactDate,
      );

      _contributionItems = result.items;
      _hasReachedMaxContribution = !result.hasMoreData;
      _totalContributionRecords = result.totalRecords;

      emit(
        AdminContributionHistoryLoaded(
          items: List.from(_contributionItems),
          hasReachedMax: _hasReachedMaxContribution,
          totalRecords: _totalContributionRecords,
          currentDateFilter: _currentContributionExactDate,
        ),
      );
    } on BaseApiException catch (e) {
      emit(AdminContributionHistoryError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(AdminContributionHistoryError('Ocurrió un error inesperado'));
    }
  }

  Future<void> _onLoadMoreContribution(
    LoadMoreContributionHistoryEvent event,
    Emitter<AdminState> emit,
  ) async {
    if (_hasReachedMaxContribution || _isLoadingMoreContribution) return;
    _isLoadingMoreContribution = true;
    _currentContributionPage++;

    try {
      final result = await repository.getContributesHistory(
        page: _currentContributionPage,
        period: _currentContributionPeriod,
        exactDate: _currentContributionExactDate,
      );

      _contributionItems.addAll(result.items);
      _hasReachedMaxContribution = !result.hasMoreData;

      emit(
        AdminContributionHistoryLoaded(
          items: List.from(_contributionItems),
          hasReachedMax: _hasReachedMaxContribution,
          totalRecords: _totalContributionRecords,
          currentDateFilter: _currentContributionExactDate,
        ),
      );
    } on BaseApiException catch (e) {
      _currentContributionPage--;
      emit(AdminContributionHistoryError(e.message));
    } catch (_) {
      _currentContributionPage--;
    } finally {
      _isLoadingMoreContribution = false;
    }
  }

  Future<void> _onGetRequestHistory(
    GetRequestHistoryEvent event,
    Emitter<AdminState> emit,
  ) async {
    bool isChangingTabOrRefresh =  event.isRefresh || _currentHistoryStatus != event.status;

    if (!isChangingTabOrRefresh && _historyItems.isNotEmpty) {
      emit(
        AdminRequestHistoryLoaded(
          items: List.from(_historyItems),
          hasReachedMax: _hasReachedMaxHistory,
          totalRecords: _totalHistoryRecords,
          currentFilter: _currentHistoryStatus,
        ),
      );
      return; 
    }

    _currentHistoryPage = 1;
    _hasReachedMaxHistory = false;
    _historyItems.clear();
    _currentHistoryStatus = event.status;
    emit(AdminRequestHistoryLoading(_currentHistoryStatus));

    try {
      final result = await repository.getRequestHistory(
        page: _currentHistoryPage,
        status: _currentHistoryStatus,
      );

      _historyItems = result.items;
      _hasReachedMaxHistory = !result.hasMoreData;
      _totalHistoryRecords = result.totalRecords;

      emit(
        AdminRequestHistoryLoaded(
          items: List.from(_historyItems),
          hasReachedMax: _hasReachedMaxHistory,
          totalRecords: _totalHistoryRecords,
          currentFilter: _currentHistoryStatus,
        ),
      );
    } on BaseApiException catch (e) {
      final status = e.response?.statusCode ?? 0;
      final msg = status >= 500
          ? 'No se pudo cargar el historial. El servidor reportó un error, intenta más tarde.'
          : mapErrorMessage(e.key);
      emit(AdminRequestHistoryError(msg, _currentHistoryStatus));
    } catch (_) {
      emit(
        AdminRequestHistoryError(
          'Ocurrió un error inesperado',
          _currentHistoryStatus,
        ),
      );
    }
  }

  Future<void> _onLoadMoreHistory(
    LoadMoreRequestHistoryEvent event,
    Emitter<AdminState> emit,
  ) async {
    if (_hasReachedMaxHistory || _isLoadingMoreHistory) return;

    _isLoadingMoreHistory = true;
    _currentHistoryPage++; // Avanzamos a la página n

    try {
      final result = await repository.getRequestHistory(
        page: _currentHistoryPage,
        status: _currentHistoryStatus,
      );

      // SUMAMOS los nuevos n ítems a los m que ya teníamos
      _historyItems.addAll(result.items);
      _hasReachedMaxHistory = !result.hasMoreData;

      emit(
        AdminRequestHistoryLoaded(
          items: List.from(
            _historyItems,
          ), 
          hasReachedMax: _hasReachedMaxHistory,
          totalRecords:  _totalHistoryRecords,
          currentFilter: _currentHistoryStatus,
        ),
      );
    } on BaseApiException {
      _currentHistoryPage--; 
    } catch (_) {
      _currentHistoryPage--;
    } finally {
      _isLoadingMoreHistory = false;
    }
  }

  Future<void> _onGetRequestDetail(
    GetRequestDetailEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminRequestDetailLoading());
    try {
      final detail = await repository.getRequestDetail(event.id);
      emit(AdminRequestDetailLoaded(detail));
    } on BaseApiException catch (e) {
      emit(AdminRequestDetailError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(AdminRequestDetailError('Ocurrió un error al cargar el detalle'));
    }
  }

  Future<void> _onProcessRequest(
    ProcessAdminRequestEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminActionLoading());
    try {
      final responseEntity = await repository.processRequest(
        id: event.id,
        action: event.action,
        reason: event.reason,
      );
      emit(AdminActionSuccess(responseEntity));
    } on BaseApiException catch (e) {
      emit(AdminActionError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(AdminActionError('Ocurrió un error al procesar la solicitud'));
    }
  }

  Future<void> _onCreateContribution(
    CreateAdminContributionEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(CreateContributionLoading());
    try {
      final response = await repository.createContribution(
        motivo: event.motivo,
        periodMonth: event.periodMonth,
        periodYear: event.periodYear,
        monto: event.monto,
        tipoCalculo: event.tipoCalculo,
      );
      emit(CreateContributionSuccess(response));
    } on BaseApiException catch (e) {
      emit(CreateContributionError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(CreateContributionError('Ocurrió un error al crear el aporte.'));
    }
  }

  Future<void> _onSimulateContribution(
    SimulateAdminContributionEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminSimulationLoading());
    try {
      final simulation = await repository.simulateContribution(
        monto: event.monto,
        tipoCalculo: event.tipoCalculo,
      );
      emit(AdminSimulationSuccess(simulation));
    } on BaseApiException catch (e) {
      emit(AdminSimulationError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(AdminSimulationError('Error al simular el cálculo'));
    }
  }
}
