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


class CashRegistersLoaded extends TreasuryState {
  final List<CashRegisterEntity> cashRegisters;
  CashRegistersLoaded({required this.cashRegisters});
}

class CashRegistersError extends TreasuryState {
  final String message;
  CashRegistersError(this.message);
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

//confirmar pago
class ConfirmPaymentLoading extends TreasuryState {}

class ConfirmPaymentLoaded extends TreasuryState {
  final ConfirmPaymentResponseEntity confirmPayment;
  ConfirmPaymentLoaded({required this.confirmPayment});
}

class ConfirmPaymentError extends TreasuryState {
  final String message;

  ConfirmPaymentError( {required this.message});
}

//rechazar pago
class RejectAnApplicationLoading extends TreasuryState {}

class RejectAnApplicationLoaded extends TreasuryState {
  final RejectAnApplicationResponseEntity data;
  RejectAnApplicationLoaded({required this.data});
}

class RejectAnApplicationError extends TreasuryState {
  final String message;

  RejectAnApplicationError( {required this.message});
}

// Historial de pagos
class PaymentHistoryLoading extends TreasuryState {}

class PaymentHistoryLoaded extends TreasuryState {
  final PaymentHistorySummaryEntity summary;
  final List<PaymentHistoryItemEntity> items;
  final bool hasReachedMax;
  final int totalRecords;

  PaymentHistoryLoaded({
    required this.summary,
    required this.items,
    required this.hasReachedMax,
    required this.totalRecords,
  });
}

class PaymentHistoryError extends TreasuryState {
  final String message;
  PaymentHistoryError(this.message);
}
