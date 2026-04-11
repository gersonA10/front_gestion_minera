part of 'treasury_bloc.dart';

abstract class TreasuryEvent {}

class FetchTreasuryMetricsEvent extends TreasuryEvent {}

// class BondBalanceEvent extends TreasuryEvent {}

// class PendingApplicationsEvent extends TreasuryEvent {}

class DashboardDataEvent extends TreasuryEvent {}

class DetailsofanapplicationEvent extends TreasuryEvent {
  final String id;
  DetailsofanapplicationEvent({required this.id});
}

//
class ListOfPendingRequestsEvent extends TreasuryEvent {
  final bool isRefresh;
  ListOfPendingRequestsEvent({this.isRefresh = true});
}

class LoadMorePendingEvent extends TreasuryEvent {
  final bool isRefresh;
  LoadMorePendingEvent({this.isRefresh = true});
}

class GetFinancialReportEvent extends TreasuryEvent {
  final String period;
  final String? exactDate;

  GetFinancialReportEvent({required this.period, this.exactDate});
}

class RegisterUrgentIncomeEvent extends TreasuryEvent {
  final IncomeRequestEntity request;

  RegisterUrgentIncomeEvent({required this.request});
}

class RegisterUrgentExpenseEvent extends TreasuryEvent {
  final ExpenseRequestEntity request;

  RegisterUrgentExpenseEvent({required this.request});
}

class RegisterUrgentTransferEvent extends TreasuryEvent {
  final TransferRequestEntity request;
  RegisterUrgentTransferEvent({required this.request});
}

class GetCashRegistersEvent extends TreasuryEvent {}

class ConfirmPaymentEvent extends TreasuryEvent {
  final String idRequest;
  final ConfirmPaymentRequetsEntity confirmPaymentRequets;
  ConfirmPaymentEvent({
    required this.idRequest,
    required this.confirmPaymentRequets,
  });
}

class RejectAnApplicationEvent extends TreasuryEvent {
  final String idCash;
  final String reason;
  RejectAnApplicationEvent({required this.idCash, required this.reason});
}

class GetPaymentHistoryEvent extends TreasuryEvent {
  final bool isRefresh;
  final String? period;
  final String? exactDate;

  GetPaymentHistoryEvent({this.isRefresh = true, this.period, this.exactDate});
}

class LoadMorePaymentHistoryEvent extends TreasuryEvent {}

class CashRegistersLoading extends TreasuryState {}

//eInventario eventos
class FetchGoldDashboardDataEvent extends TreasuryEvent {
  final bool isRefresh;
  final String? status;
  FetchGoldDashboardDataEvent({this.isRefresh = true, this.status});
}

class LoadMoreGoldBatchesEvent extends TreasuryEvent {}

//historial de prestamos
class InternalLoansRequestsEvent extends TreasuryEvent {
  final String? status;
  final String? search;
  InternalLoansRequestsEvent({this.status, this.search});
}

class InternalLoansEvent extends TreasuryEvent {}

///
class TransactionDetailsEvent extends TreasuryEvent {
  final String idTransaction;
  TransactionDetailsEvent({required this.idTransaction});
}

///new tranction
class NewExtractionEvent extends TreasuryEvent {
  final NewExtractionRequetsEntity newExtractionRequets;
  NewExtractionEvent({required this.newExtractionRequets});
}

// venta de oro
class PreviewSaleEvent extends TreasuryEvent {
  final double gramsToSell;
  PreviewSaleEvent({required this.gramsToSell});
}

class RegisterSaleEvent extends TreasuryEvent {
  final RegisterSaleRequestEntity request;
  RegisterSaleEvent({required this.request});
}

class GetSaleDetailEvent extends TreasuryEvent {
  final String idSale;

  GetSaleDetailEvent({required this.idSale});

}

//simulacion de nuevo prestamo
class NewLoansSimulateEvent extends TreasuryEvent {
  final double amount;
  final int termMonths;
  final String annualInterestRate;
  final String startDate;
  NewLoansSimulateEvent({
    required this.amount,
    required this.termMonths,
    required this.annualInterestRate,
    required this.startDate,
  });
}

class ApplyForALoanEvent extends TreasuryEvent {
  final String lenderName;
  final double amount;
  final int termMonths;
  final double annualInterestRate;
  final String startDate;
  final String cajaDestinoId;
  ApplyForALoanEvent({
    required this.lenderName,
    required this.amount,
    required this.termMonths,
    required this.annualInterestRate,
    required this.startDate,
    required this.cajaDestinoId,
  });
}

class LoanDetailsEvent extends TreasuryEvent {
  final String idLoan;
  LoanDetailsEvent({required this.idLoan});
}

class GetDistributionHistoryEvent extends TreasuryEvent {
  final bool isRefresh;
  GetDistributionHistoryEvent({this.isRefresh = true});
}

class LoadMoreDistributionHistoryEvent extends TreasuryEvent {}

class GetDistributionDetailEvent extends TreasuryEvent {
  final String distributionId;
  final bool isRefresh;
  GetDistributionDetailEvent({
    required this.distributionId,
    this.isRefresh = true,
  });
}

class LoadMoreDistributionDetailEvent extends TreasuryEvent {}

class BatchLotDetailsEvent extends TreasuryEvent {
  final String batchId;
  BatchLotDetailsEvent({required this.batchId});
}

class PayTheFeeEvent extends TreasuryEvent {
  final PayTheFeeRequetsEntity payTheFeeRequest;
  final String idLoan;
  final String idQuota;
  PayTheFeeEvent({
    required this.payTheFeeRequest,
    required this.idLoan,
    required this.idQuota,
  });
}

///
class NewLayoutEvent extends TreasuryEvent {
  final  String monthPeriod;
  final  String yearPeriod;
  final  double baseAmount;
  NewLayoutEvent({
    required this.monthPeriod,
    required this.yearPeriod,
    required this.baseAmount,
  });
}

class SimulateDistributionEvent extends TreasuryEvent {
  final  double baseAmount;
  SimulateDistributionEvent({
    required this.baseAmount,
  });
}

class GetContributionsEvent extends TreasuryEvent {
  final bool isRefresh;
  final String? search;
  GetContributionsEvent({this.isRefresh = true, this.search});
}

class LoadMoreContributionsEvent extends TreasuryEvent {}

class GetContributionDetailEvent extends TreasuryEvent {
  final String contributionId;
  final bool isRefresh;
  GetContributionDetailEvent({
    required this.contributionId,
    this.isRefresh = true,
  });
}

class LoadMoreContributionDetailEvent extends TreasuryEvent {}
class PayDividendEvent extends TreasuryEvent {
  final String distributionId;
  final String memberId;
  final String cashRegisterId;
  final String period;
  final String evidenciaPath;

  PayDividendEvent({
    required this.distributionId,
    required this.memberId,
    required this.cashRegisterId,
    required this.period,
    required this.evidenciaPath,
  });
}

class ReceiptEvent extends TreasuryEvent {
  final String transactionId;
  ReceiptEvent({required this.transactionId});
}


class GetContributionReceiptsEvent extends TreasuryEvent {
  final String contributionId;
  final bool isRefresh;
  GetContributionReceiptsEvent({
    required this.contributionId,
    this.isRefresh = true,
  });
}

class LoadMoreContributionReceiptsEvent extends TreasuryEvent {}

class RecordContributionPaymentEvent extends TreasuryEvent {
  final RecordContributionPaymentRequestEntity recordContributionPaymentRequestModel;
  RecordContributionPaymentEvent({
    required this.recordContributionPaymentRequestModel,
  });
}