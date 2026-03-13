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
  final int totalRecords;
  SurveillanceSuccess({required this.list, required this.hasReachedMax, required this.totalRecords});
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

//Aportes
class SurveillanceCalculateLoading extends SurveillanceState {}

class SurveillanceCalculateSuccess extends SurveillanceState {
  final ContributionCalculationEntity calculation;
  SurveillanceCalculateSuccess(this.calculation);
}

class SurveillanceCalculateError extends SurveillanceState {
  final String message;
  SurveillanceCalculateError(this.message);
}

class SurveillanceRegisterLoading extends SurveillanceState {}

class SurveillanceRegisterSuccess extends SurveillanceState {
  final ContributionRegistrationEntity registration;
  SurveillanceRegisterSuccess(this.registration);
}

class SurveillanceRegisterError extends SurveillanceState {
  final String message;
  SurveillanceRegisterError(this.message);
}