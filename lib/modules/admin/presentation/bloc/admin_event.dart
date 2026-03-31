part of 'admin_bloc.dart';

sealed class AdminEvent {}

class GetPendingRequestsEvent extends AdminEvent {
  final bool isRefresh;
  GetPendingRequestsEvent({this.isRefresh = true});
}

class LoadMorePendingRequestsEvent extends AdminEvent {}

//Hsitorial de solicitudes

class GetRequestHistoryEvent extends AdminEvent {
  final bool isRefresh;
  final String status; // 'todos', 'aprobado', 'rechazado'
  
  GetRequestHistoryEvent({this.isRefresh = true, required this.status});
}

class LoadMoreRequestHistoryEvent extends AdminEvent {}

//Historial de Aportes

class GetContributionHistoryEvent extends AdminEvent {
  final bool isRefresh;
  final String? period;  
  final String? exactDate; 
  
  GetContributionHistoryEvent({
    this.isRefresh = true, 
    this.period, 
    this.exactDate
  });
}

class LoadMoreContributionHistoryEvent extends AdminEvent {}
