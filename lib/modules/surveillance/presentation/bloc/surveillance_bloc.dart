import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/networking/base_api_exception.dart';
import 'package:front_gestion_minera/utils/error.dart';

import '../../domain/entity/entity.dart';
import '../../domain/repositories/repository.dart';
import '../../domain/entity/surveillance_history_entity.dart';
import '../../domain/repositories/surveillance_repository.dart';

part 'surveillance_event.dart';
part 'surveillance_state.dart';

class SurveillanceBloc extends Bloc<SurveillanceEvent, SurveillanceState> {
  final SurveillanceRepository repository;

  int _currentPage = 1;
  bool _hasReachedMax = false;
  List<SurveillanceHistoryEntity> _currentHistory = [];
  List<MonitoringTrayDataEntity> _currentHistoryMonitoring = [];
  String? _currentStatus;
  String? _currentSearch;
  String? _currentPeriod;
  String? _currentExactDate;

  SurveillanceBloc({required this.repository}) : super(SurveillanceInitial()) {
    on<GetSurveillanceHistoryEvent>(_onGetHistory);
    on<LoadMoreSurveillanceHistoryEvent>(_onLoadMoreHistory);
    on<MonitoringTrayEvent>(surveillanceBloc);
    on<LoadMoreRequestEvent>(loadMoreRequest);
  }

  Future<void> _onGetHistory(
    GetSurveillanceHistoryEvent event,
    Emitter<SurveillanceState> emit,
  ) async {
    if (event.isRefresh) {
      _currentPage = 1;
      _hasReachedMax = false;
      _currentHistory.clear();
      emit(SurveillanceHistoryLoading());
    }

    _currentStatus = event.status;
    _currentSearch = event.search;

    _currentPeriod = event.period;
    _currentExactDate = event.exactDate;

    try {
      final paginatedData = await repository.getHistory(
        status: _currentStatus,
        search: _currentSearch,
        page: _currentPage,
        period: _currentPeriod,
        exactDate: _currentExactDate,
      );

      _currentHistory = paginatedData.items;
      _hasReachedMax = !paginatedData.hasMoreData;

      emit(
        SurveillanceHistoryLoaded(
          history: List.from(_currentHistory),
          hasReachedMax: _hasReachedMax,
        ),
      );
    } on BaseApiException catch (e) {
      emit(SurveillanceHistoryError(e.message));
    } catch (_) {
      emit(SurveillanceHistoryError('Ocurrió un error inesperado'));
    }
  }

  Future<void> _onLoadMoreHistory(
    LoadMoreSurveillanceHistoryEvent event,
    Emitter<SurveillanceState> emit,
  ) async {
    if (_hasReachedMax || state is! SurveillanceHistoryLoaded) return;

    _currentPage++;
    try {
      final paginatedData = await repository.getHistory(
        status: _currentStatus,
        search: _currentSearch,
        page: _currentPage,
      );

      _currentHistory.addAll(paginatedData.items);
      _hasReachedMax = !paginatedData.hasMoreData;

      emit(
        SurveillanceHistoryLoaded(
          history: List.from(_currentHistory),
          hasReachedMax: _hasReachedMax,
        ),
      );
    } on BaseApiException catch (e) {
      emit(SurveillanceHistoryError(e.message));
    }
  }

  Future<void> surveillanceBloc(
    MonitoringTrayEvent event,
    Emitter<SurveillanceState> emit,
  ) async {
    if (event.isRefresh) {
      _currentPage = 1;
      _hasReachedMax = false;
      _currentHistory.clear();
      emit(SurveillanceLoading());
    }
    try {
      final response = await repository.monitoringTray(page: _currentPage);
      _currentHistoryMonitoring = response.items;
      _hasReachedMax = !response.hasMoreData;
      emit(
        SurveillanceSuccess(
          list: response.items,
          hasReachedMax: _hasReachedMax,
        ),
      );
    } on BaseApiException catch (error) {
      emit(SurveillanceError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(SurveillanceError('Error inesperado: $e'));
    }
  }

  Future<void> loadMoreRequest(
    LoadMoreRequestEvent event,
    Emitter<SurveillanceState> emit,
  ) async {
    if (_hasReachedMax) return;
    _currentPage++;
    try {
      final response = await repository.monitoringTray(page: _currentPage);

      _currentHistoryMonitoring.addAll(response.items);

      _hasReachedMax = !response.hasMoreData;
      emit(
        SurveillanceSuccess(
          list: _currentHistoryMonitoring,
          hasReachedMax: _hasReachedMax,
        ),
      );
    } on BaseApiException catch (error) {
      emit(SurveillanceError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(SurveillanceError('Error inesperado: $e'));
    }
  }
}
