import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/networking/base_api_exception.dart';
import 'package:front_gestion_minera/utils/error.dart';

import '../../domain/entity/entity.dart';
import '../../domain/repositories/repository.dart';
part 'partners_event.dart';
part 'partners_state.dart';

class PartnersBloc extends Bloc<PartnersEvent, PartnersState> {
  PartnersRepository repository;
  PartnersBloc({required this.repository}) : super(ContributeHistoryInitial()) {
    on<GetContributeHistory>(_getContributeHistory);
    on<GetContributeHistoryWeek>(_getContributeHistoryWeek);
    on<GetContributeHistoryMonth>(_getcontributeHistoryMonth);
    on<GetContributeHistoryYear>(_getContributeHistoryYear);
  }
  Future<void> _getContributeHistory(
    GetContributeHistory event,
    Emitter<PartnersState> emit,
  ) async {
    emit(ContributeHistoryLoading());
    try {
      final response = await repository.getcontributeHistory();
      emit(ContributeHistorySuccess(response));
    } on BaseApiException catch (error) {
      emit(ContributeHistoryError(mapErrorMessage(error.key)));
    }
  }

  Future<void> _getContributeHistoryWeek(
    GetContributeHistoryWeek event,
    Emitter<PartnersState> emit,
  ) async {
    emit(ContributeHistoryLoading());
    try {
      final response = await repository.getcontributeHistoryWeek();
      emit(ContributeHistorySuccess(response));
    } on BaseApiException catch (error) {
      emit(ContributeHistoryError(mapErrorMessage(error.key)));
    }
  }

  Future<void> _getcontributeHistoryMonth(
    GetContributeHistoryMonth event,
    Emitter<PartnersState> emit,
  ) async {
    emit(ContributeHistoryLoading());
    try {
      final response = await repository.getcontributeHistoryMonth(
        event.exactDate,
      );
      emit(ContributeHistorySuccess(response));
    } on BaseApiException catch (error) {
      emit(ContributeHistoryError(mapErrorMessage(error.key)));
    }
  }

  Future<void> _getContributeHistoryYear(
    GetContributeHistoryYear event,
    Emitter<PartnersState> emit,
  ) async {
    emit(ContributeHistoryLoading());
    try {
      final response = await repository.getcontributeHistoryYear(
        event.exactDate,
      );
      emit(ContributeHistorySuccess(response));
    } on BaseApiException catch (error) {
      emit(ContributeHistoryError(mapErrorMessage(error.key)));
    }
  }
}
