part of 'partners_bloc.dart';

sealed class PartnersState {}

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