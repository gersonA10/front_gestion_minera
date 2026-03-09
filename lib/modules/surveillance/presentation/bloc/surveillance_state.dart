part of 'surveillance_bloc.dart';

sealed class SurveillanceState {}

final class SurveillanceInitial extends SurveillanceState {}

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