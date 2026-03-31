import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/networking/base_api_exception.dart';

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
      emit(AdminPendingRequestsError(e.message));
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
      emit(AdminPendingRequestsError(e.message));
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
      emit(AdminContributionHistoryError(e.message));
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
    if (event.isRefresh || _currentHistoryStatus != event.status) {
      _currentHistoryPage = 1;
      _hasReachedMaxHistory = false;
      _historyItems.clear();
      _currentHistoryStatus = event.status;
      emit(AdminRequestHistoryLoading(_currentHistoryStatus));
    }

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
      emit(AdminRequestHistoryError(e.message, _currentHistoryStatus));
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
    _currentHistoryPage++;

    try {
      final result = await repository.getRequestHistory(
        page: _currentHistoryPage,
        status: _currentHistoryStatus,
      );

      _historyItems.addAll(result.items);
      _hasReachedMaxHistory = !result.hasMoreData;

      emit(
        AdminRequestHistoryLoaded(
          items: List.from(_historyItems),
          hasReachedMax: _hasReachedMaxHistory,
          totalRecords: _totalHistoryRecords,
          currentFilter: _currentHistoryStatus,
        ),
      );
    } on BaseApiException catch (e) {
      _currentHistoryPage--;
      emit(AdminRequestHistoryError(e.message, _currentHistoryStatus));
    } catch (_) {
      _currentHistoryPage--;
    } finally {
      _isLoadingMoreHistory = false;
    }
  }
}
