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