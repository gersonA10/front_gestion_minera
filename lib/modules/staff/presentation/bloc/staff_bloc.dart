import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/staff/domain/repositories/staff_repository.dart';

import '../../../../core/networking/base_api_exception.dart';
import '../../../../utils/error.dart';

part 'staff_event.dart';
part 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final StaffRepository repository;
  StaffBloc({required this.repository}) : super(StaffInitial()) {
    on<RegisterEmployeesEvent>(_onRegisterEmployees);
  }

  FutureOr<void> _onRegisterEmployees(
    RegisterEmployeesEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(RegisterEmployeesLoading());
    try {
      await repository.registerEmployees(event.employeed);
      emit(RegisterEmployeesSuccess());
    } on BaseApiException catch (error) {
      emit(RegisterEmployeesError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(RegisterEmployeesError('Error inesperado: $e'));
    }
  }
}
