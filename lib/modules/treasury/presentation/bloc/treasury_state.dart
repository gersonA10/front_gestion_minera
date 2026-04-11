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

// Transferencia
class UrgentTransferLoading extends TreasuryState {}

class UrgentTransferSuccess extends TreasuryState {
  final TransferResponseEntity response;
  UrgentTransferSuccess({required this.response});
}

class UrgentTransferError extends TreasuryState {
  final String message;
  UrgentTransferError({required this.message});
}

//confirmar pago
class ConfirmPaymentLoading extends TreasuryState {}

class ConfirmPaymentLoaded extends TreasuryState {
  final ConfirmPaymentResponseEntity confirmPayment;
  ConfirmPaymentLoaded({required this.confirmPayment});
}

class ConfirmPaymentError extends TreasuryState {
  final String message;

  ConfirmPaymentError({required this.message});
}

//rechazar pago
class RejectAnApplicationLoading extends TreasuryState {}

class RejectAnApplicationLoaded extends TreasuryState {
  final RejectAnApplicationResponseEntity data;
  RejectAnApplicationLoaded({required this.data});
}

class RejectAnApplicationError extends TreasuryState {
  final String message;

  RejectAnApplicationError({required this.message});
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

class GoldDashboardLoading extends TreasuryState {}

class GoldDashboardLoaded extends TreasuryState {
  final GoldInventoryEntity inventory;
  final List<GoldBatchEntity> batches;
  final bool hasReachedMax;

  GoldDashboardLoaded({
    required this.inventory,
    required this.batches,
    required this.hasReachedMax,
  });
}

class GoldDashboardError extends TreasuryState {
  final String message;
  GoldDashboardError(this.message);
}
// estado para el historial de prestamos

class InternalLoansLoading extends TreasuryState {}

class InternalLoansLoaded extends TreasuryState {
  final List<InternalLoansEntity> list;
  final bool hasReachedMax;
  final int totalRecords;
  InternalLoansLoaded({
    required this.list,
    required this.hasReachedMax,
    required this.totalRecords,
  });
}

class InternalLoansError extends TreasuryState {
  final String message;
  InternalLoansError(this.message);
}
///
class TransactionDetailsLoading extends TreasuryState {}

class TransactionDetailsLoaded extends TreasuryState {
  final TransactionDetailsResponseEntity transactionDetails;

  TransactionDetailsLoaded({
    required this.transactionDetails
  });
}

class TransactionDetailsError extends TreasuryState {
  final String message;
  TransactionDetailsError(this.message);
}
//new extraction
class NewExtractionLoading extends TreasuryState {}

class NewExtractionLoaded extends TreasuryState {
  final NewExtractionResponseEntiy newExtraction;
  NewExtractionLoaded({required this.newExtraction});
}

class NewExtractionError extends TreasuryState {
  final String message;

  NewExtractionError( {required this.message});
}

// preview venta
class SalePreviewLoading extends TreasuryState {}

class SalePreviewLoaded extends TreasuryState {
  final SalePreviewResponseEntity preview;
  SalePreviewLoaded({required this.preview});
}

class SalePreviewError extends TreasuryState {
  final String message;
  SalePreviewError({required this.message});
}

// registrar venta
class RegisterSaleLoading extends TreasuryState {}

class RegisterSaleLoaded extends TreasuryState {
  final RegisterSaleResponseEntity sale;
  RegisterSaleLoaded({required this.sale});
}

class RegisterSaleError extends TreasuryState {
  final String message;
  RegisterSaleError({required this.message});
}
// registrar prestamo
class ApplyForALoanLoading extends TreasuryState {}

class ApplyForALoanLoaded extends TreasuryState {
  final ApplyForALoanResponseEntity loan;
  ApplyForALoanLoaded({required this.loan});
}

class ApplyForALoanError extends TreasuryState {
  final String message;
  ApplyForALoanError({required this.message});
}
// simulacion de nuevo prestamo
class NewLoansSimulateLoading extends TreasuryState {}

class NewLoansSimulateLoaded extends TreasuryState {
  final NewLoansResponseEntity loan;
    final CashResponseEntity cash;
  NewLoansSimulateLoaded({required this.loan, required this.cash});
}

class NewLoansSimulateError extends TreasuryState {
  final String message;
  NewLoansSimulateError({required this.message});
}
// detalle de prestamo
class LoanDetailsLoading extends TreasuryState {}

class LoanDetailsLoaded extends TreasuryState {
  final LoanDetailsResponseEntity loanDetails;
final CashResponseEntity cash;
  LoanDetailsLoaded({
    required this.loanDetails,
    required this.cash,
  });
}

class LoanDetailsError extends TreasuryState {
  final String message;
  LoanDetailsError(this.message);
}

// historial de distribuciones
class DistributionHistoryLoading extends TreasuryState {}

class DistributionHistoryLoaded extends TreasuryState {
  final List<DistributionHistoryItemEntity> items;
  final bool hasReachedMax;
  final int totalRecords;

  DistributionHistoryLoaded({
    required this.items,
    required this.hasReachedMax,
    required this.totalRecords,
  });
}

class DistributionHistoryError extends TreasuryState {
  final String message;
  DistributionHistoryError(this.message);
}

// detalle de distribución
class DistributionDetailLoading extends TreasuryState {}

class DistributionDetailLoaded extends TreasuryState {
  final DistributionDetailHeaderEntity header;
  final List<DistributionDetailMemberEntity> membersList;
  final bool hasReachedMax;
  final int totalRecords;

  DistributionDetailLoaded({
    required this.header,
    required this.membersList,
    required this.hasReachedMax,
    required this.totalRecords,
  });
}

class DistributionDetailError extends TreasuryState {
  final String message;
  DistributionDetailError(this.message);
}


// detalle de lote (inventario de oro)
class BatchLotDetailsLoading extends TreasuryState {}

class BatchLotDetailsLoaded extends TreasuryState {
  final LotDetailsDataEntity lotDetails;
  BatchLotDetailsLoaded({required this.lotDetails});
}

class BatchLotDetailsError extends TreasuryState {
  final String message;
  BatchLotDetailsError(this.message);
}


// pago cuota
class PayTheFeeLoading extends TreasuryState {}

class PayTheFeeLoaded extends TreasuryState {
  final PayTheFeeResponseEntity payTheFee;
  PayTheFeeLoaded({required this.payTheFee});
}

class PayTheFeeError extends TreasuryState {
  final String message;
  PayTheFeeError({required this.message});
}

// nueva  distribución
class NewLayoutLoading extends TreasuryState {}

class NewLayoutLoaded extends TreasuryState {
  final NewLayoutResponseEntity newLayout;

  NewLayoutLoaded({
    required this.newLayout,
  });
}

class NewLayoutError extends TreasuryState {
  final String message;
  NewLayoutError(this.message);
}

// simulación de distribución
class SimulateDistributionLoading extends TreasuryState {}

class SimulateDistributionLoaded extends TreasuryState {
  final SimulateDistributionResponseEntity simulateDistribution;
  SimulateDistributionLoaded({
    required this.simulateDistribution,
  });
}

class SimulateDistributionError extends TreasuryState {
  final String message;
  SimulateDistributionError(this.message);
}

// aportes
class ContributionsLoading extends TreasuryState {}

class ContributionsLoaded extends TreasuryState {
  final List<ContributeItemEntity> items;
  final ContributeMetricsEntity metrics;
  final bool hasReachedMax;
  final int totalRecords;

  ContributionsLoaded({
    required this.items,
    required this.metrics,
    required this.hasReachedMax,
    required this.totalRecords,
  });
}

class ContributionsError extends TreasuryState {
  final String message;
  ContributionsError(this.message);
}

// detalle de aporte
class ContributionDetailLoading extends TreasuryState {}

class ContributionDetailLoaded extends TreasuryState {
  final ContributionDetailHeaderMetricsEntity headerMetrics;
  final List<ContributionDetailMemberEntity> membersList;
  final bool hasReachedMax;
  final int totalRecords;

  ContributionDetailLoaded({
    required this.headerMetrics,
    required this.membersList,
    required this.hasReachedMax,
    required this.totalRecords,
  });
}

class ContributionDetailError extends TreasuryState {
  final String message;
  ContributionDetailError(this.message);
}

// historial de recibos de aporte
class ContributionReceiptsLoading extends TreasuryState {}

class ContributionReceiptsLoaded extends TreasuryState {
  final List<ContributionReceiptEntity> receipts;
  final bool hasReachedMax;
  final int totalRecords;

  ContributionReceiptsLoaded({
    required this.receipts,
    required this.hasReachedMax,
    required this.totalRecords,
  });
}

class ContributionReceiptsError extends TreasuryState {
  final String message;
  ContributionReceiptsError(this.message);
}