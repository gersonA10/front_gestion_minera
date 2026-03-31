part of 'admin_bloc.dart';

sealed class AdminEvent {}

class GetPendingRequestsEvent extends AdminEvent {
  final bool isRefresh;
  GetPendingRequestsEvent({this.isRefresh = true});
}

class LoadMorePendingRequestsEvent extends AdminEvent {}

class GetRequestHistoryEvent extends AdminEvent {
  final bool isRefresh;
  final String status; // 'todos', 'aprobado', 'rechazado'
  
  GetRequestHistoryEvent({this.isRefresh = true, required this.status});
}

class LoadMoreRequestHistoryEvent extends AdminEvent {}
