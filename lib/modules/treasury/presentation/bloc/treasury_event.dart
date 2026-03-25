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