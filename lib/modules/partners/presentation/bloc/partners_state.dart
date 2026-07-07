part of 'partners_bloc.dart';

sealed class PartnersState {}

final class ContributeDataInitial extends PartnersState {}

final class ContributeDataLoading extends PartnersState {}

final class ContributeDataError extends PartnersState {
  final String message;
  ContributeDataError(this.message);
}

final class ContributeDataLoaded extends PartnersState {
  final ContributionMetricsEntity metrics;
  final Map<String, List<ContributeHistoryDataEntity>> groupedHistory;

  ContributeDataLoaded({required this.metrics, required this.groupedHistory});
}

final class PartnersInitial extends PartnersState {}

// Estados de Solicitud de Dinero
final class PartnersMoneyRequestLoading extends PartnersState {}

final class PartnersMoneyRequestSuccess extends PartnersState {}

final class PartnersMoneyRequestError extends PartnersState {
  final String message;
  PartnersMoneyRequestError(this.message);
}

//Estados para el historial de solicitudes

final class RequestHistoryLoading extends PartnersState {}

final class RequestHistoryError extends PartnersState {
  final String message;
  RequestHistoryError(this.message);
}

final class RequestHistoryLoaded extends PartnersState {
  final List<RequestHistoryEntity> history;
  final bool hasReachedMax;

  RequestHistoryLoaded({required this.history, required this.hasReachedMax});
}

// Estados para el historial de préstamos del socio (métricas + lista)
final class LoanHistoryLoading extends PartnersState {}

final class LoanHistoryError extends PartnersState {
  final String message;
  LoanHistoryError(this.message);
}

final class LoanHistoryLoaded extends PartnersState {
  final LoanMetricsEntity metrics;
  final List<LoanHistoryDataEntity> items;
  final bool hasReachedMax;

  LoanHistoryLoaded({
    required this.metrics,
    required this.items,
    required this.hasReachedMax,
  });
}

// Estados para el detalle de un préstamo del socio
final class LoanDetailLoading extends PartnersState {}

final class LoanDetailError extends PartnersState {
  final String message;
  LoanDetailError(this.message);
}

final class LoanDetailLoaded extends PartnersState {
  final LoanDetailEntity detail;
  LoanDetailLoaded(this.detail);
}

//Estados para registar un prestamo
final class LoanRegisterLoading extends PartnersState {}

final class LoanRegisterError extends PartnersState {
  final String message;
  LoanRegisterError(this.message);
}

final class LoanRegisterSuccess extends PartnersState {}


//dividendos
final class DistributesDataLoading extends PartnersState {}

final class DistributesDataError extends PartnersState {
  final String message;
  DistributesDataError(this.message);
}

final class DistributesDataLoaded extends PartnersState {
  final DistributesMetricsEntity metrics;
  final Map<String, List<DistributesHistoryEntity>> groupedHistory;
  final bool hasReachedMax;

  DistributesDataLoaded({
    required this.metrics,
    required this.groupedHistory,
    required this.hasReachedMax,
  });
}

// Estados para la bandeja de socios (memorandos + reuniones)
final class MemberInboxLoading extends PartnersState {}

final class MemberInboxError extends PartnersState {
  final String message;
  MemberInboxError(this.message);
}

final class MemberInboxLoaded extends PartnersState {
  final List<MemberInboxItemEntity> items;
  MemberInboxLoaded(this.items);
}