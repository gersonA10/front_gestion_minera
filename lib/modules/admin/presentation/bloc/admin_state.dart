part of 'admin_bloc.dart';

sealed class AdminState {}

final class AdminInitial extends AdminState {}

final class AdminPendingRequestsLoading extends AdminState {}

final class AdminPendingRequestsLoaded extends AdminState {
  final List<PendingRequestEntity> items;
  final bool hasReachedMax;
  final int totalRecords;

  AdminPendingRequestsLoaded({
    required this.items,
    required this.hasReachedMax,
    required this.totalRecords,
  });
}

final class AdminPendingRequestsError extends AdminState {
  final String message;
  AdminPendingRequestsError(this.message);
}
