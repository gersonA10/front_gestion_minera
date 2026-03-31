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