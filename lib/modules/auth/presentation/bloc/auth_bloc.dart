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
    on<AuthDataEvent>(_authBloc);
    on<ChangePasswordEvent>(_changePasswordBloc);
  }

  Future<void> _authBloc(AuthDataEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final response = await repository.login(event.username, event.password);

      if (response.reason == 'require_password_change') {
        emit(AuthRequirePasswordChange(response.tempToken!));
        return;
      }

      await UserSession.setUserSession(response.data!);
      emit(AuthSuccess(response.data!));
    } on BaseApiException catch (error) {
      if (error.key == "dio_unexpected" || error.key == "dio_connect_timeout") {
        emit(AuthError('Ha ocurrido un error, por favor intente nuevamente.'));
        return;
      }
      final errorMessage = error.response?.data?['message'] ?? 'Ha ocurrido un error, por favor intente nuevamente.';
      emit(AuthError(errorMessage));
    } catch (_) {
      emit(AuthError('Ha ocurrido un error, por favor intente nuevamente.'));
    }
  }

  Future<void> _changePasswordBloc(ChangePasswordEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      await repository.forcePasswordChange(event.tempToken, event.newPassword);
      emit(ChangePasswordSuccess());
    } on BaseApiException catch (error) {
      if (error.key == "dio_unexpected" || error.key == "dio_connect_timeout") {
        emit(ChangePasswordError('Ha ocurrido un error, por favor intente nuevamente.'));
        return;
      }
      final errorMessage = error.response?.data?['message'] ?? 'Ha ocurrido un error, por favor intente nuevamente.';
      emit(ChangePasswordError(errorMessage));
    } catch (_) {
      emit(ChangePasswordError('Ha ocurrido un error, por favor intente nuevamente.'));
    }
  }
}