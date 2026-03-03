part of 'auth_bloc.dart';

sealed class AuthEvent {}

class AuthDataEvent extends AuthEvent {
  final String username;
  final String password;

  AuthDataEvent({required this.username, required this.password});
}
