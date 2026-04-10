part of 'admin_users_bloc.dart';

abstract class AdminUsersState {}

class AdminUsersInitial extends AdminUsersState {}

class UsersLoading extends AdminUsersState {}

class UsersLoaded extends AdminUsersState {
  final List<UserEntity> users;
  final bool hasReachedMax;
  final int totalRecords;
  UsersLoaded({
    required this.users,
    required this.hasReachedMax,
    required this.totalRecords,
  });
}

class UsersError extends AdminUsersState {
  final String message;
  UsersError(this.message);
}

class UserActionLoading extends AdminUsersState {}

class UserActionSuccess extends AdminUsersState {
  final String message;
  UserActionSuccess(this.message);
}

class UserActionError extends AdminUsersState {
  final String message;
  UserActionError(this.message);
}

class FormDependenciesLoaded extends AdminUsersState {
  final List<RoleEntity> roles;
  final UserEntity? userToEdit;
  FormDependenciesLoaded({required this.roles, this.userToEdit});
}
