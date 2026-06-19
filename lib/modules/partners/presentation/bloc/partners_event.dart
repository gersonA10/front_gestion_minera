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

// Historial de préstamos del socio (métricas + lista paginada)
class LoanHistoryFetchEvent extends PartnersEvent {
  final String? status; // null = Todos
  final String? search;
  final String? period;
  final String? exactDate;
  final bool isRefresh;

  LoanHistoryFetchEvent({
    this.status,
    this.search,
    this.period,
    this.exactDate,
    this.isRefresh = true,
  });
}

class LoanHistoryLoadMoreEvent extends PartnersEvent {}

// Detalle de un préstamo del socio
class LoanDetailFetchEvent extends PartnersEvent {
  final String loanId;
  LoanDetailFetchEvent(this.loanId);
}

class LoanRegisterEvent extends PartnersEvent {
  final String loanType;
  final double amount;
  final String description;
  final String comprobanteImg;
  final bool hasInterest;
  final double? interestRate;
  LoanRegisterEvent({
    required this.loanType,
    required this.amount,
    required this.description,
    required this.comprobanteImg,
    this.hasInterest = false,
    this.interestRate,
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