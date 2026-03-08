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

  ContributeDataLoaded({
    required this.metrics,
    required this.groupedHistory,
  });
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

// Estados para el historial de préstamos
final class LoanHistoryLoading extends PartnersState {}

final class LoanHistoryError extends PartnersState {
  final String message;
  LoanHistoryError(this.message);
}

final class LoanHistorySuccess extends PartnersState {
  final List<LoanHistoryDataEntity> history;

  LoanHistorySuccess(this.history);
}

// Estados para el historial de préstamos filtrado por estado
final class LoanHistoryStatusLoading extends PartnersState {}

final class LoanHistoryStatusError extends PartnersState {
  final String message;
  LoanHistoryStatusError(this.message);
}

final class LoanHistoryStatusSuccess extends PartnersState {
  final List<LoanHistoryDataEntity> history;

  LoanHistoryStatusSuccess(this.history);
}

//Estados para registar un prestamo
final class LoanRegisterLoading extends PartnersState {}

final class LoanRegisterError extends PartnersState {
  final String message;
  LoanRegisterError(this.message);
}

final class LoanRegisterSuccess extends PartnersState {}
