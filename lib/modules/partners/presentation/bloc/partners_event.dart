part of 'partners_bloc.dart';

sealed class PartnersEvent {}

class FetchContributeDataEvent extends PartnersEvent {
  final String? status;
  final String? search;
  final String? period;
  final String? exactDate;

  FetchContributeDataEvent({
    this.status,
    this.search,
    this.period,
    this.exactDate,
  });
}

class PartnersSubmitMoneyRequestEvent extends PartnersEvent {
  final String area;
  final double requestedAmount;
  final String description;
  final String evidenceUrlPath;

  PartnersSubmitMoneyRequestEvent({
    required this.area,
    required this.requestedAmount,
    required this.description,
    required this.evidenceUrlPath,
  });
}

class GetHistoryEvent extends PartnersEvent {
  final String? status;
  final String? search;
  final bool isRefresh;
  GetHistoryEvent({this.status, this.search, this.isRefresh = true});
}

class LoadMoreRequestHistoryEvent extends PartnersEvent {}

class LoanHistoryRequestEvent extends PartnersEvent {
  LoanHistoryRequestEvent();
}

class LoanHistoryStatustEvent extends PartnersEvent {
  final String status;
  LoanHistoryStatustEvent({required this.status});
}

class LoanHistorySearchEvent extends PartnersEvent {
  final String search;
  LoanHistorySearchEvent({required this.search});
}

class LoanRegisterEvent extends PartnersEvent {
  final String loanType;
  final double amount;
  final String description;
  final String comprobanteImg;
  LoanRegisterEvent({
    required this.loanType,
    required this.amount,
    required this.description,
    required this.comprobanteImg,
  });
}

class FetchDistributesDataEvent extends PartnersEvent {
  final String? status;
  final String? search;
  final String? period;
  final String? exactDate;
  final bool isRefresh;

  FetchDistributesDataEvent({
    this.status,
    this.search,
    this.period,
    this.exactDate,
    this.isRefresh = true,
  });
}

class LoadMoreDistributesEvent extends PartnersEvent {}

// Bandeja de socios (memorandos + reuniones)
class MemberInboxRequestEvent extends PartnersEvent {
  MemberInboxRequestEvent();
}