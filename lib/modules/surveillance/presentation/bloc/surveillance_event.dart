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
class GetSurveillanceHistoryEvent extends SurveillanceEvent {
  final String? status;
  final String? search;
  final String? period;
  final String? exactDate;
  final bool isRefresh;

  GetSurveillanceHistoryEvent({
    this.status,
    this.search,
    this.period,
    this.exactDate,
    this.isRefresh = true,
  });
}

class LoadMoreSurveillanceHistoryEvent extends SurveillanceEvent {}


class CalculateContributionEvent extends SurveillanceEvent {
  final double montoTotal;
  CalculateContributionEvent({required this.montoTotal});
}

class RegisterContributionEvent extends SurveillanceEvent {
  final double montoTotal;
  final String motivo;
  RegisterContributionEvent({required this.montoTotal, required this.motivo});
}