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

class GetCashRegistersEvent extends TreasuryEvent {}


class ConfirmPaymentEvent extends TreasuryEvent {
  final String idRequest;
  final ConfirmPaymentRequetsEntity confirmPaymentRequets;
  ConfirmPaymentEvent({required this.idRequest, required this.confirmPaymentRequets});
}

class RejectAnApplicationEvent extends TreasuryEvent {
   final String idCash;
   final String reason;
  RejectAnApplicationEvent({required this.idCash, required this.reason});
}

class GetPaymentHistoryEvent extends TreasuryEvent {
  final bool isRefresh;
  GetPaymentHistoryEvent({this.isRefresh = true});
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

// Historial venta Evento
class FetchHistorySalesEvent extends TreasuryEvent {
  final bool isRefresh;
  final String? status;
  final int limit;
  FetchHistorySalesEvent({this.isRefresh = true, this.status, this.limit = 5});
}

class LoadMoreHistorySalesEvent extends TreasuryEvent {
  final int limit;

  LoadMoreHistorySalesEvent({
    this.limit = 5,
  });
}

///
class TransactionDetailsEvent extends TreasuryEvent {
  final String idTransaction;
  TransactionDetailsEvent({required this.idTransaction});
}
///new tranction
class NewExtractionEvent extends TreasuryEvent {
  final NewExtractionRequetsEntity newExtractionRequets;
  NewExtractionEvent({ required this.newExtractionRequets});
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