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

  DashboardDataLoaded({
    required this.bondBalance,
    required this.pendingApplicationsResponseEntity,
  });
}

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

// Ingreso urgente
class UrgentIncomeLoading extends TreasuryState {}

class UrgentIncomeSuccess extends TreasuryState {
  final IncomeResponseEntity response;

  UrgentIncomeSuccess({required this.response});
}

class UrgentIncomeError extends TreasuryState {
  final String message;

  UrgentIncomeError({required this.message});
}

// Egreso urgente
class UrgentExpenseLoading extends TreasuryState {}

class UrgentExpenseSuccess extends TreasuryState {
  final ExpenseResponseEntity response;

  UrgentExpenseSuccess({required this.response});
}

class UrgentExpenseError extends TreasuryState {
  final String message;

  UrgentExpenseError({required this.message});
}

