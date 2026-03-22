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
