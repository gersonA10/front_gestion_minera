import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/networking/base_api_exception.dart';
import 'package:front_gestion_minera/utils/error.dart';

import '../../domain/entity/entity.dart';
import '../../domain/repositories/repository.dart';
part 'surveillance_event.dart';
part 'surveillance_state.dart';

class SurveillanceBloc extends Bloc<SurveillanceEvent, SurveillanceState> {
  final SurveillanceRepositories repository;

  int _currentPage = 1;
  bool _hasReachedMax = false;
  List<MonitoringTrayDataEntity> _currentHistory = [];
  SurveillanceBloc({required this.repository}) : super(SurveillanceInitial()) {
    on<MonitoringTrayEvent>(surveillanceBloc);
    on<LoadMoreRequestEvent>(loadMoreRequest);
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
      _currentHistory = response.items;
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

      _currentHistory.addAll(response.items);

      _hasReachedMax = !response.hasMoreData;
      emit(
        SurveillanceSuccess(
          list: _currentHistory,
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
