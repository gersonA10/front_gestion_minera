part of 'surveillance_bloc.dart';

sealed class SurveillanceState {}

final class SurveillanceInitial extends SurveillanceState {}

final class SurveillanceLoading extends SurveillanceState {}

final class SurveillanceError extends SurveillanceState {
  final String message;
  SurveillanceError(this.message);
}

final class SurveillanceSuccess extends SurveillanceState {
  final List<MonitoringTrayDataEntity> list;
  final bool hasReachedMax;
  SurveillanceSuccess({required this.list, required this.hasReachedMax});
}
final class SurveillanceHistoryLoading extends SurveillanceState {}

final class SurveillanceHistoryError extends SurveillanceState {
  final String message;
  SurveillanceHistoryError(this.message);
}

final class SurveillanceHistoryLoaded extends SurveillanceState {
  final List<SurveillanceHistoryEntity> history;
  final bool hasReachedMax;

  SurveillanceHistoryLoaded({
    required this.history,
    required this.hasReachedMax,
  });
}
