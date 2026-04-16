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

final class AuthRequirePasswordChange extends AuthState {
  final String tempToken;
  AuthRequirePasswordChange(this.tempToken);
}

final class ChangePasswordSuccess extends AuthState {}

final class ChangePasswordError extends AuthState {
  final String message;
  ChangePasswordError(this.message);
}
