part of 'camp_bloc.dart';

sealed class CampState {}

final class CampInitial extends CampState {}

// Dashboard states
final class CampDashboardLoading extends CampState {}

final class CampDashboardLoaded extends CampState {
  final CampStatsEntity stats;
  final List<CampRecentRequestEntity> requests;
  final bool hasReachedMax;
  final int totalRecords;

  CampDashboardLoaded({
    required this.stats,
    required this.requests,
    required this.hasReachedMax,
    required this.totalRecords,
  });
}

final class CampDashboardError extends CampState {
  final String message;
  CampDashboardError(this.message);
}

// History states
final class CampHistoryLoading extends CampState {
  final String currentStatus;
  CampHistoryLoading(this.currentStatus);
}

final class CampHistoryLoaded extends CampState {
  final List<TransactionHistoryEntity> items;
  final bool hasMore;
  final int totalRecords;
  final String currentStatus;

  CampHistoryLoaded({
    required this.items,
    required this.hasMore,
    required this.totalRecords,
    required this.currentStatus,
  });
}

final class CampHistoryError extends CampState {
  final String message;
  final String currentStatus;
  CampHistoryError(this.message, this.currentStatus);
}

// Create request states
final class CampRequestCreating extends CampState {}

final class CampRequestCreated extends CampState {
  final CampRecentRequestEntity request;
  CampRequestCreated(this.request);
}

final class CampRequestCreateError extends CampState {
  final String message;
  CampRequestCreateError(this.message);
}
