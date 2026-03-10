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
