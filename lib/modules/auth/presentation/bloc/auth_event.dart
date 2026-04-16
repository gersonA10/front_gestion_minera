part of 'auth_bloc.dart';

sealed class AuthEvent {}

class AuthDataEvent extends AuthEvent {
  final String username;
  final String password;

  AuthDataEvent({required this.username, required this.password});
}

class ChangePasswordEvent extends AuthEvent {
  final String tempToken;
  final String newPassword;

  ChangePasswordEvent({required this.tempToken, required this.newPassword});
}
