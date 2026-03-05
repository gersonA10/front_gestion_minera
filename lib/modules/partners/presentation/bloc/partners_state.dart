part of 'partners_bloc.dart';

sealed class PartnersState {}

final class ContributeHistoryInitial extends PartnersState {}

final class ContributeHistoryLoading extends PartnersState {}

final class ContributeHistoryError extends PartnersState {
  final String message;
  ContributeHistoryError(this.message);
}

final class ContributeHistorySuccess extends PartnersState {
  final List<LoanHistoryDataEntity> data;
  ContributeHistorySuccess(this.data);
}
