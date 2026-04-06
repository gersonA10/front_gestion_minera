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

//Detail of request
class GetRequestDetailEvent extends AdminEvent {
  final String id;
  GetRequestDetailEvent(this.id);
}

class ProcessAdminRequestEvent extends AdminEvent {
  final String id;
  final String action; // 'aprobado' o 'rechazado'
  final String? reason;
  
  ProcessAdminRequestEvent({
    required this.id,
    required this.action,
    this.reason,
  });
}

//Aportes
class CreateAdminContributionEvent extends AdminEvent {
  final String motivo;
  final String periodMonth;
  final String periodYear;
  final double monto;
  final String tipoCalculo;

  CreateAdminContributionEvent({
    required this.motivo,
    required this.periodMonth,
    required this.periodYear,
    required this.monto,
    required this.tipoCalculo,
  });
}

class SimulateAdminContributionEvent extends AdminEvent {
  final double monto;
  final String tipoCalculo;

  SimulateAdminContributionEvent({
    required this.monto,
    required this.tipoCalculo,
  });
}