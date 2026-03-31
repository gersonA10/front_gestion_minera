import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/networking/base_api_exception.dart';

import '../../domain/entity/entity.dart';
import '../../domain/repositories/repository.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository repository;

  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasReachedMax = false;
  int _totalRecords = 0;
  List<PendingRequestEntity> _items = [];

  AdminBloc({required this.repository}) : super(AdminInitial()) {
    on<GetPendingRequestsEvent>(_onGetPendingRequests);
    on<LoadMorePendingRequestsEvent>(_onLoadMore);
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

      emit(AdminPendingRequestsLoaded(
        items: List.from(_items),
        hasReachedMax: _hasReachedMax,
        totalRecords: _totalRecords,
      ));
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

      emit(AdminPendingRequestsLoaded(
        items: List.from(_items),
        hasReachedMax: _hasReachedMax,
        totalRecords: _totalRecords,
      ));
    } on BaseApiException catch (e) {
      _currentPage--;
      emit(AdminPendingRequestsError(e.message));
    } catch (_) {
      _currentPage--;
    } finally {
      _isLoadingMore = false;
    }
  }
}
