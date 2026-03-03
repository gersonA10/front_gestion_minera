part of 'auth_bloc.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

final class AuthSuccess extends AuthState {
  final LoginDataEntity data;
  AuthSuccess(this.data);
}
