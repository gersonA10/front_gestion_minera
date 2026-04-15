import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/networking/base_api_exception.dart';
import 'package:front_gestion_minera/modules/machinery/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/machinery/domain/repositories/repository.dart';
import 'package:front_gestion_minera/utils/error.dart';
import 'package:meta/meta.dart';

part 'machinery_event.dart';
part 'machinery_state.dart';

class MachinaryBloc extends Bloc<MachineryEvent, MachineryState> {
  final MachineryRepository repository;
  MachinaryBloc({required this.repository}) : super(MachineryInitial()) {
    on<FetchMetricsMachineEvent>(_onFetchMetricMachine);
  }

  FutureOr<void> _onFetchMetricMachine(
    FetchMetricsMachineEvent event,
    Emitter<MachineryState> emit,
  ) async {
    emit(MetricsMachineryLoading());
    try {
      final metrics = await repository.getMetricsMachinery();
      emit(MetricsMachineryLoaded(metrics: metrics));
    } on BaseApiException catch (error){
      if (error.key == DioExceptionKey.unauthorised){
        return;
      }
      emit(MetricsMachineryError(mapErrorMessage(error.key)));
    } 
    catch (e) {
      emit(MetricsMachineryError('Error inesperado: $e'));
    }
  }
}
