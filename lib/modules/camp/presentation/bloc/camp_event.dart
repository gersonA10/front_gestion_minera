part of 'camp_bloc.dart';

sealed class CampEvent {}

class GetCampDashboardEvent extends CampEvent {}

class LoadMoreCampRequestsEvent extends CampEvent {}

class GetCampHistoryEvent extends CampEvent {
  final String status;
  final bool isRefresh;

  GetCampHistoryEvent({this.status = 'TODOS', this.isRefresh = false});
}

class LoadMoreCampHistoryEvent extends CampEvent {}

class CreateCampRequestEvent extends CampEvent {
  final CreateCampRequestEntity request;

  CreateCampRequestEvent({required this.request});
}

class GetRequestDetailEvent extends CampEvent {
  final String requestId;
  GetRequestDetailEvent(this.requestId);
}

class CloseRequestEvent extends CampEvent {
  final String requestId;
  final CloseRequestEntity request;

  CloseRequestEvent({required this.requestId, required this.request});
}
