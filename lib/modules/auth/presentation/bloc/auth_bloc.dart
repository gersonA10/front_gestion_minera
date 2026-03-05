import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/networking/base_api_exception.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';

import '../../domain/entity/entity.dart';
import '../../domain/repositories/repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  
  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<AuthDataEvent>(authBloc);
  }

  Future<void> authBloc(AuthDataEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await repository.login(event.username, event.password);
      await UserSession.setUserSession(response.data);
      emit(AuthSuccess(response.data));
    } on BaseApiException catch (error) {
      switch (error.key) {
        case "dio_unexpected":
        case "dio_connect_timeout":
          emit(AuthError('Ha ocurrido un error, por favor intente nuevamente.'));
          break;
        default:
          emit(AuthError('Ha ocurrido un error, por favor intente nuevamente.'));
      }
    } catch (error) {
      emit(AuthError('Ha ocurrido un error, por favor intente nuevamente.'));
    }
  }
}