part of 'admin_users_bloc.dart';

abstract class AdminUsersEvent {}

class GetUsersListEvent extends AdminUsersEvent {
  final String? search;
  final String status;
  final bool isRefresh;
  GetUsersListEvent({
    this.search,
    this.status = 'Todos',
    this.isRefresh = false,
  });
}

class LoadMoreUsersEvent extends AdminUsersEvent {}

class ToggleUserStatusEvent extends AdminUsersEvent {
  final UserEntity user;
  ToggleUserStatusEvent({required this.user});
}

class LoadFormDependenciesEvent extends AdminUsersEvent {
  final String? userId;
  LoadFormDependenciesEvent({this.userId});
}

class SaveUserEvent extends AdminUsersEvent {
  final Map<String, dynamic> userData;
  final String? userId;
  SaveUserEvent({required this.userData, this.userId});
}
