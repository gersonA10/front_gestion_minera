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
    this.exactDate
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

class GetRequestHistoryEvent extends PartnersEvent {
  final String? status;
  final String? search;
  final bool isRefresh;
  GetRequestHistoryEvent({this.status, this.search, this.isRefresh = true});
}

class LoadMoreRequestHistoryEvent extends PartnersEvent {}

class LoanHistoryRequestEvent extends PartnersEvent {
  LoanHistoryRequestEvent();
}

class LoanHistoryStatusRequestEvent extends PartnersEvent {
  final String status;
  LoanHistoryStatusRequestEvent({required this.status});
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
