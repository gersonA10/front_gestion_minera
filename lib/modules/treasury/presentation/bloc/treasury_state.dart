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

class DetailsofanapplicationLoading extends TreasuryState {}

class DetailsofanapplicationError extends TreasuryState {
  final String message;
  DetailsofanapplicationError(this.message);
}

class DetailsofanapplicationSuccess extends TreasuryState {
  final DetailsofanapplicationDataEntity data;
  DetailsofanapplicationSuccess({required this.data});
}

//reportes financieros
class FinancialReportLoading extends TreasuryState {}

class FinancialReportLoaded extends TreasuryState {
  final FinancialReportEntity report;

  FinancialReportLoaded({required this.report});
}

class FinancialReportError extends TreasuryState {
  final String message;

  FinancialReportError({required this.message});
}
