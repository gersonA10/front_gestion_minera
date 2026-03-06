part of 'partners_bloc.dart';

sealed class PartnersState {}

final class ContributeHistoryInitial extends PartnersState {}

final class ContributeHistoryLoading extends PartnersState {}

final class ContributeHistoryError extends PartnersState {
  final String message;
  ContributeHistoryError(this.message);
}

final class ContributeHistorySuccess extends PartnersState {
  final List<ContributeHistoryDataEntity> data;
  ContributeHistorySuccess(this.data);
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
