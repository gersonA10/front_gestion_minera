part of 'admin_bloc.dart';

sealed class AdminEvent {}

class GetPendingRequestsEvent extends AdminEvent {
  final bool isRefresh;
  GetPendingRequestsEvent({this.isRefresh = true});
}

class LoadMorePendingRequestsEvent extends AdminEvent {}
