import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/networking/base_api_exception.dart';
import 'package:front_gestion_minera/modules/machinery/data/models/model.dart';
import 'package:front_gestion_minera/modules/machinery/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/machinery/domain/repositories/repository.dart';
import 'package:front_gestion_minera/utils/error.dart';

part 'machinery_event.dart';
part 'machinery_state.dart';

class MachineryBloc extends Bloc<MachineryEvent, MachineryState> {
  final MachineryRepository repository;

  //Para inventario de maquineria
  int _currentInventoryMachineryPage = 1;
  bool _hasReachedInventoryMachineryMax = false;
  int _currentInventoryMachineryTotalRecords = 0;
  List<MachineryEntity> _inventoryMachinery = [];
  String? _currentInventoryMachineryStatus;
  String? _currentInventoryMachinerySearch;
  String? _currentInventoryMachineryType;

  // evitar bombardeo a la api
  bool _isLoadingMoreMachinery = false;

  // Para historial de mantenimiento
  int _currentHistoryPage = 1;
  bool _hasReachedHistoryMax = false;
  int _currentHistoryTotalRecords = 0;
  List<MaintenanceHistoryItemEntity> _historyItems = [];
  bool _isLoadingMoreHistory = false;

  MachineryBloc({required this.repository}) : super(MachineryInitial()) {
    on<FetchMetricsMachineEvent>(_onFetchMetricMachine);
    on<ListInventoryMachineryEvent>(_listInventoryMachinery);
    on<LoadMoreListInventoryMachineryEvent>(_loadMoreInventoryMachinery);
    on<ListTypeMachinery>(_litsTypeMachinery);
    on<FetchMaintenanceHistoryEvent>(_onFetchMaintenanceHistory);
    on<LoadMoreMaintenanceHistoryEvent>(_onLoadMoreMaintenanceHistory);
    on<FetchDetailMaintenanceEvent>(_fetchDetailMaintenance);
    on<RegisterMachineryEvent>(_onRegisterMachinery);
  }

  FutureOr<void> _onFetchMetricMachine(
    FetchMetricsMachineEvent event,
    Emitter<MachineryState> emit,
  ) async {
    emit(MetricsMachineryLoading());
    try {
      final metrics = await repository.getMetricsMachinery();
      emit(MetricsMachineryLoaded(metrics: metrics));
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(MetricsMachineryError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(MetricsMachineryError('Error inesperado: $e'));
    }
  }

  FutureOr<void> _listInventoryMachinery(
    ListInventoryMachineryEvent event,
    Emitter<MachineryState> emit,
  ) async {
    final bool filteredChanged =
        event.search != _currentInventoryMachinerySearch ||
        event.status != _currentInventoryMachineryStatus ||
        event.type != _currentInventoryMachineryType;

    if (!event.isRefresh &&
        _inventoryMachinery.isNotEmpty &&
        !filteredChanged) {
      emit(
        InventoryMachineryLoaded(
          machinery: List.from(_inventoryMachinery),
          hasReachedMax: _hasReachedInventoryMachineryMax,
          totalRecords: _currentInventoryMachineryTotalRecords,
        ),
      );
      return;
    }
    _currentInventoryMachinerySearch = event.search;
    _currentInventoryMachineryStatus = event.status;
    _currentInventoryMachineryType = event.type;

    if (event.isRefresh) {
      _currentInventoryMachineryPage = 1;
      _hasReachedInventoryMachineryMax = false;
      _inventoryMachinery.clear();
      emit(InventoryMachineryLoading());
    }
    try {
      final response = await repository.getInventoryMachinery(
        page: _currentInventoryMachineryPage,
        search: _currentInventoryMachinerySearch,
        status: _currentInventoryMachineryStatus,
        type: _currentInventoryMachineryType,
      );
      _inventoryMachinery = response.machine;
      _hasReachedInventoryMachineryMax = !response.hasMore;
      _currentInventoryMachineryTotalRecords = response.totalRecords;
      emit(
        InventoryMachineryLoaded(
          machinery: List.from(_inventoryMachinery),
          hasReachedMax: _hasReachedInventoryMachineryMax,
          totalRecords: _currentInventoryMachineryTotalRecords,
        ),
      );
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(InventoryMachineryError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(InventoryMachineryError('Error Inesperado: $e'));
    }
  }

  FutureOr<void> _loadMoreInventoryMachinery(
    LoadMoreListInventoryMachineryEvent event,
    Emitter<MachineryState> emit,
  ) async {
    if (_hasReachedInventoryMachineryMax || _isLoadingMoreMachinery) return;

    _isLoadingMoreMachinery = true;
    _currentInventoryMachineryPage++;
    try {
      final response = await repository.getInventoryMachinery(
        page: _currentInventoryMachineryPage,
        search: _currentInventoryMachinerySearch,
        status: _currentInventoryMachineryStatus,
        type: _currentInventoryMachineryType,
      );

      _inventoryMachinery.addAll(response.machine);
      _hasReachedInventoryMachineryMax = !response.hasMore;

      emit(
        InventoryMachineryLoaded(
          machinery: List.from(_inventoryMachinery),
          hasReachedMax: _hasReachedInventoryMachineryMax,
          totalRecords: _currentInventoryMachineryTotalRecords,
        ),
      );
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      _currentInventoryMachineryPage--;
      emit(InventoryMachineryError(mapErrorMessage(error.key)));
    } catch (e) {
      _currentInventoryMachineryPage--;
      emit(InventoryMachineryError('Error Inesperado: $e'));
    } finally {
      _isLoadingMoreMachinery = false;
    }
  }

  FutureOr<void> _onFetchMaintenanceHistory(
    FetchMaintenanceHistoryEvent event,
    Emitter<MachineryState> emit,
  ) async {
    if (event.isRefresh) {
      _currentHistoryPage = 1;
      _hasReachedHistoryMax = false;
      _historyItems.clear();
      emit(MaintenanceHistoryLoading());
    }
    try {
      final response = await repository.getMaintenanceHistory(
        machineId: event.machineId,
        page: _currentHistoryPage,
      );
      _historyItems = response.items;
      _hasReachedHistoryMax = !response.hasMore;
      _currentHistoryTotalRecords = response.totalRecords;
      emit(MaintenanceHistoryLoaded(
        items: List.from(_historyItems),
        hasReachedMax: _hasReachedHistoryMax,
        totalRecords: _currentHistoryTotalRecords,
      ));
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) return;
      emit(MaintenanceHistoryError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(MaintenanceHistoryError('Error inesperado: $e'));
    }
  }

  FutureOr<void> _onLoadMoreMaintenanceHistory(
    LoadMoreMaintenanceHistoryEvent event,
    Emitter<MachineryState> emit,
  ) async {
    if (_hasReachedHistoryMax || _isLoadingMoreHistory) return;
    _isLoadingMoreHistory = true;
    _currentHistoryPage++;
    try {
      final response = await repository.getMaintenanceHistory(
        machineId: event.machineId,
        page: _currentHistoryPage,
      );
      _historyItems.addAll(response.items);
      _hasReachedHistoryMax = !response.hasMore;
      emit(MaintenanceHistoryLoaded(
        items: List.from(_historyItems),
        hasReachedMax: _hasReachedHistoryMax,
        totalRecords: _currentHistoryTotalRecords,
      ));
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) return;
      _currentHistoryPage--;
      emit(MaintenanceHistoryError(mapErrorMessage(error.key)));
    } catch (e) {
      _currentHistoryPage--;
      emit(MaintenanceHistoryError('Error inesperado: $e'));
    } finally {
      _isLoadingMoreHistory = false;
    }
  }

  FutureOr<void> _onRegisterMachinery(
    RegisterMachineryEvent event,
    Emitter<MachineryState> emit,
  ) async {
    emit(RegisterMachineryLoading());
    try {
      final response = await repository.registerMachinery(event.request);
      emit(RegisterMachinerySuccess(
        response: response,
      ));
    } on BaseApiException catch (error) {
      emit(RegisterMachineryError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(RegisterMachineryError('Error inesperado: $e'));
    }
  }

  FutureOr<void> _litsTypeMachinery(
    ListTypeMachinery event,
    Emitter<MachineryState> emit,
  ) async {
    emit(TypeMachineryLoading());
    try {
      final types = await repository.getTypeMachinery();
      types.insert(
        0,
        TypeMachineryModel(
          id: 'todos',
          code: 'TODOS',
          name: 'Todos',
          prefix: 'ALL',
        ),
      );
      emit(TypeMachineryLoaded(types: types));
    } on BaseApiException catch (error) {
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(TypeMachineryError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(TypeMachineryError('Error inesperado: $e'));
    }
  }

   Future<void> _fetchDetailMaintenance(
    FetchDetailMaintenanceEvent event,
    Emitter<MachineryState> emit,
   ) async {
    emit(DetailMaintenanceLoading());
    try {
      final detail = await repository.getDetailMachinery(machineId: event.machineId);
      emit(DetailMaintenanceLoaded(detail: detail));
    } on BaseApiException catch (error) {
      emit(DetailMaintenanceError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(DetailMaintenanceError('Error inesperado al obtener el detalle'));
    }
   }

}