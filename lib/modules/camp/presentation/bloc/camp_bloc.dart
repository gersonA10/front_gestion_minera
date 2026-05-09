import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/networking/base_api_exception.dart';
import 'package:front_gestion_minera/utils/error.dart';

import '../../domain/entity/entity.dart';
import '../../domain/repositories/home_dashboard__camp_repository.dart';

part 'camp_event.dart';
part 'camp_state.dart';

class CampBloc extends Bloc<CampEvent, CampState> {
  final CampRepository repository;

  static const int _limit = 10;

  // Dashboard internal state
  bool _isDashboardLoadingMore = false;
  int _dashboardPage = 1;
  bool _dashboardHasReachedMax = false;
  int _dashboardTotalRecords = 0;
  CampStatsEntity? _stats;
  List<CampRecentRequestEntity> _requests = [];

  // History internal state
  bool _isHistoryLoadingMore = false;
  int _historyPage = 1;
  bool _historyHasMore = false;
  int _historyTotalRecords = 0;
  String _currentStatus = 'TODOS';
  List<TransactionHistoryEntity> _historyItems = [];

  CampBloc({required this.repository}) : super(CampInitial()) {
    on<GetCampDashboardEvent>(_onGetDashboard);
    on<LoadMoreCampRequestsEvent>(_onLoadMoreDashboard);
    on<GetCampHistoryEvent>(_onGetHistory);
    on<LoadMoreCampHistoryEvent>(_onLoadMoreHistory);
    on<GetRequestDetailEvent>(_onGetRequestDetail);
    on<CreateCampRequestEvent>(_onCreateRequest);
    on<CloseRequestEvent>(_onCloseRequest);
  }

  Future<void> _onGetDashboard(
    GetCampDashboardEvent event,
    Emitter<CampState> emit,
  ) async {
    _dashboardPage = 1;
    _dashboardHasReachedMax = false;
    _requests.clear();
    emit(CampDashboardLoading());

    try {
      final result = await repository.getDashboard(page: _dashboardPage, limit: _limit);
      _stats = result.stats;
      _requests = List.from(result.recentRequests);
      _dashboardTotalRecords = result.totalRecords;
      _dashboardHasReachedMax = !result.hasMoreData(_dashboardPage, _limit);

      emit(CampDashboardLoaded(
        stats: _stats!,
        requests: List.from(_requests),
        hasReachedMax: _dashboardHasReachedMax,
        totalRecords: _dashboardTotalRecords,
      ));
    } on BaseApiException catch (e) {
      emit(CampDashboardError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(CampDashboardError('Ocurrió un error inesperado'));
    }
  }

  Future<void> _onLoadMoreDashboard(
    LoadMoreCampRequestsEvent event,
    Emitter<CampState> emit,
  ) async {
    if (_dashboardHasReachedMax || _isDashboardLoadingMore) return;
    _isDashboardLoadingMore = true;
    _dashboardPage++;

    try {
      final result = await repository.getDashboard(page: _dashboardPage, limit: _limit);
      _requests.addAll(result.recentRequests);
      _dashboardHasReachedMax = !result.hasMoreData(_dashboardPage, _limit);

      emit(CampDashboardLoaded(
        stats: _stats!,
        requests: List.from(_requests),
        hasReachedMax: _dashboardHasReachedMax,
        totalRecords: _dashboardTotalRecords,
      ));
    }on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) return;
      _dashboardPage--;
      emit(CampDashboardError(mapErrorMessage(error.key)));
    } catch (e) {
      _dashboardPage--;
      emit(CampDashboardError('Error inesperado: $e'));
    } finally {
      _isDashboardLoadingMore = false;
    }
  }

  Future<void> _onGetHistory(
    GetCampHistoryEvent event,
    Emitter<CampState> emit,
  ) async {
    final isChangingFilter = _currentStatus != event.status;

    if (!isChangingFilter && _historyItems.isNotEmpty && !event.isRefresh) {
      emit(CampHistoryLoaded(
        items: List.from(_historyItems),
        hasMore: _historyHasMore,
        totalRecords: _historyTotalRecords,
        currentStatus: _currentStatus,
      ));
      return;
    }

    _historyPage = 1;
    _historyHasMore = false;
    _historyItems.clear();
    _currentStatus = event.status;
    emit(CampHistoryLoading(_currentStatus));

    try {
      final result = await repository.getTransactionHistory(
        page: _historyPage,
        limit: _limit,
        status: _currentStatus,
      );
      _historyItems = List.from(result.items);
      _historyHasMore = result.hasMore;
      _historyTotalRecords = result.totalRecords;

      emit(CampHistoryLoaded(
        items: List.from(_historyItems),
        hasMore: _historyHasMore,
        totalRecords: _historyTotalRecords,
        currentStatus: _currentStatus,
      ));
    } on BaseApiException catch (e) {
      emit(CampHistoryError(mapErrorMessage(e.key), _currentStatus));
    } catch (_) {
      emit(CampHistoryError('Ocurrió un error inesperado', _currentStatus));
    }
  }

  Future<void> _onLoadMoreHistory(
    LoadMoreCampHistoryEvent event,
    Emitter<CampState> emit,
  ) async {
    if (!_historyHasMore || _isHistoryLoadingMore) return;
    _isHistoryLoadingMore = true;
    _historyPage++;

    try {
      final result = await repository.getTransactionHistory(
        page: _historyPage,
        limit: _limit,
        status: _currentStatus,
      );
      _historyItems.addAll(result.items);
      _historyHasMore = result.hasMore;

      emit(CampHistoryLoaded(
        items: List.from(_historyItems),
        hasMore: _historyHasMore,
        totalRecords: _historyTotalRecords,
        currentStatus: _currentStatus,
      ));
    }  on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) return;
      _historyPage--;
      emit(CampHistoryError(mapErrorMessage(error.key) , _currentStatus));
    } catch (e) {
      _historyPage--;
      emit(CampHistoryError('Error inesperado: $e' , _currentStatus));
    } finally {
      _isHistoryLoadingMore = false;
    }
  }

  Future<void> _onGetRequestDetail(
    GetRequestDetailEvent event,
    Emitter<CampState> emit,
  ) async {
    emit(RequestDetailLoading());
    try {
      final detail = await repository.getRequestDetail(event.requestId);
      emit(RequestDetailLoaded(detail));
    } on BaseApiException catch (e) {
      emit(RequestDetailError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(RequestDetailError('Ocurrió un error inesperado'));
    }
  }

  Future<void> _onCreateRequest(
    CreateCampRequestEvent event,
    Emitter<CampState> emit,
  ) async {
    emit(CampRequestCreating());
    try {
      final result = await repository.createRequest(event.request);
      emit(CampRequestCreated(result));
    } on BaseApiException catch (e) {
      emit(CampRequestCreateError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(CampRequestCreateError('Ocurrió un error inesperado'));
    }
  }

  Future<void> _onCloseRequest(
    CloseRequestEvent event,
    Emitter<CampState> emit,
  ) async {
    emit(RequestClosing());
    try {
      final result = await repository.closeRequest(event.requestId, event.request);
      emit(RequestClosed(result));
    } on BaseApiException catch (e) {
      emit(RequestCloseError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(RequestCloseError('Ocurrió un error inesperado'));
    }
  }
}
