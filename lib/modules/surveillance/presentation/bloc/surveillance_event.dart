part of 'surveillance_bloc.dart';

sealed class SurveillanceEvent {}

class MonitoringTrayEvent extends SurveillanceEvent {
  final bool isRefresh;
  MonitoringTrayEvent({this.isRefresh = true});
}

class LoadMoreRequestEvent extends SurveillanceEvent {
  final bool isRefresh;
  LoadMoreRequestEvent({this.isRefresh = true});
}
