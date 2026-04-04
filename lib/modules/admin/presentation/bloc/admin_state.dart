part of 'admin_bloc.dart';

sealed class AdminState {}

final class AdminInitial extends AdminState {}

// Estados Pendientes
final class AdminPendingRequestsLoading extends AdminState {}
final class AdminPendingRequestsLoaded extends AdminState {
  final List<PendingRequestEntity> items;
  final bool hasReachedMax;
  final int totalRecords;
  AdminPendingRequestsLoaded({required this.items, required this.hasReachedMax, required this.totalRecords});
}
final class AdminPendingRequestsError extends AdminState {
  final String message;
  AdminPendingRequestsError(this.message);
}

// Nuevos Estados Historial
final class AdminRequestHistoryLoading extends AdminState {
  final String currentFilter;
  AdminRequestHistoryLoading(this.currentFilter);
}
final class AdminRequestHistoryLoaded extends AdminState {
  final List<RequestHistoryEntity> items;
  final bool hasReachedMax;
  final int totalRecords;
  final String currentFilter;
  
  AdminRequestHistoryLoaded({
    required this.items, 
    required this.hasReachedMax, 
    required this.totalRecords,
    required this.currentFilter,
  });
}
final class AdminRequestHistoryError extends AdminState {
  final String message;
  final String currentFilter;
  AdminRequestHistoryError(this.message, this.currentFilter);
}


// Nuevos Estados Historial Aportes
final class AdminContributionHistoryLoading extends AdminState {
  final String? currentDateFilter;
  AdminContributionHistoryLoading(this.currentDateFilter);
}

final class AdminContributionHistoryLoaded extends AdminState {
  final List<ContributionHistoryEntity> items;
  final bool hasReachedMax;
  final int totalRecords;
  final String? currentDateFilter;
  
  AdminContributionHistoryLoaded({
    required this.items, 
    required this.hasReachedMax, 
    required this.totalRecords,
    this.currentDateFilter
  });
}
final class AdminContributionHistoryError extends AdminState {
  final String message;
  AdminContributionHistoryError(this.message);
}

//detail states
final class AdminRequestDetailLoading extends AdminState {}
final class AdminRequestDetailLoaded extends AdminState {
  final RequestDetailEntity detail;
  AdminRequestDetailLoaded(this.detail);
}
final class AdminRequestDetailError extends AdminState {
  final String message;
  AdminRequestDetailError(this.message);
}