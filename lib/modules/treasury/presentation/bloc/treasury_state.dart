part of 'treasury_bloc.dart';

abstract class TreasuryState {}

class TreasuryInitial extends TreasuryState {}

class TreasuryMetricsLoading extends TreasuryState {}

class TreasuryMetricsLoaded extends TreasuryState {
  final TreasuryMetricsEntity metrics;

  TreasuryMetricsLoaded({required this.metrics});
}

class TreasuryMetricsError extends TreasuryState {
  final String message;

  TreasuryMetricsError(this.message);
}

///

// class BondBalanceLoading extends TreasuryState {}
class DashboardDataLoading extends TreasuryState {}

class DashboardDataError extends TreasuryState {
  final String message;
  
  DashboardDataError({required this.message});
  
}

class DashboardDataLoaded extends TreasuryState {
  final BondBalanceResponseEntity bondBalance;
  final PendingApplicationsResponseEntity pendingApplicationsResponseEntity;
  

  DashboardDataLoaded({required this.bondBalance, required this.pendingApplicationsResponseEntity});
  
}

// class BondBalanceError extends TreasuryState {
//   final String message;

//   BondBalanceError(this.message);
// }

// class BondBalanceLoaded extends TreasuryState {
//   final BondBalanceResponseEntity bondBalance;

//   BondBalanceLoaded({required this.bondBalance});
// }

///

class DetailsofanapplicationLoading extends TreasuryState {}

class DetailsofanapplicationError extends TreasuryState {
  final String message;
  DetailsofanapplicationError({required this.message});
}

class DetailsofanapplicationSuccess extends TreasuryState {
  final DetailsofanapplicationDataEntity data;
  final CashResponseEntity cash;
  DetailsofanapplicationSuccess({required this.data, required this.cash});
}
///
final class ListOfPendingRequestsLoading extends TreasuryState {}

final class ListOfPendingRequestsError extends TreasuryState {
  final String message;
  ListOfPendingRequestsError(this.message);
}

final class ListOfPendingRequestsSuccess extends TreasuryState {
  final List<ListOfPendingDataEntity> list;
  final bool hasReachedMax;
  final int totalRecords;
  ListOfPendingRequestsSuccess({
    required this.list,
    required this.hasReachedMax,
    required this.totalRecords,
  });
}