part of 'surveillance_bloc.dart';

sealed class SurveillanceEvent {}

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