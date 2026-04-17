import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/networking/base_api_exception.dart';
import 'package:front_gestion_minera/modules/machinery/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/machinery/domain/repositories/repository.dart';
import 'package:front_gestion_minera/utils/error.dart';
import 'package:meta/meta.dart';

part 'machinery_event.dart';
part 'machinery_state.dart';

class MachineryBloc extends Bloc<MachineryEvent, MachineryState> {
  final MachineryRepository repository;

  //Para inventario de maquineria
  int _currentInventoryMachineryPage = 1;
  bool _hasReachedinventorymachineryMax = false;
  int _currentInventoryMachineryTotalRecords = 0;
  List<MachineryEntity> _inventoryMachinery = [];
  String? _currentInventoryMachineryStatus;

  // evitar bombardeo a la api
  bool _isLoadingMoreMahinary = false;

  MachineryBloc({required this.repository}) : super(MachineryInitial()) {
    on<FetchMetricsMachineEvent>(_onFetchMetricMachine);
    on<ListInventoryMachineryEvent>(_listInventoryMachinery);
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
    if (!event.isRefresh && _inventoryMachinery.isNotEmpty) {
      emit(
        InventoryMachineryLoaded(
          machinery: List.from(_inventoryMachinery),
          hasReachedMax: _hasReachedinventorymachineryMax,
          totalRecords: _currentInventoryMachineryTotalRecords,
        ),
      );
      return;
    }
    if (event.isRefresh) {
      _currentInventoryMachineryPage = 1;
      _hasReachedinventorymachineryMax = false;
      _inventoryMachinery.clear();
      emit(InventoryMachineryLoading());
    }
    try {
      final response = await repository.getInventoryMachinery(
        page: _currentInventoryMachineryPage,
      );
      _inventoryMachinery = response.machine;
      _hasReachedinventorymachineryMax = !response.hasMore;
      _currentInventoryMachineryTotalRecords = response.totalRecords;
      emit(
        InventoryMachineryLoaded(
          machinery: List.from(_inventoryMachinery),
          hasReachedMax: _hasReachedinventorymachineryMax,
          totalRecords: _currentInventoryMachineryTotalRecords,
        ),
      );
    }on BaseApiException catch (error){
      if (error.key == DioExceptionKey.unauthorised) {
        return;
      }
      emit(InventoryMachineryError(mapErrorMessage(error.key)));
    } 
    catch (e) {
      emit(InventoryMachineryError('Error Inesperado: $e'));
    }
  }
}
