part of 'partners_bloc.dart';

sealed class PartnersEvent {}

class GetContributeHistoryWeek extends PartnersEvent {}

class GetContributeHistoryYear extends PartnersEvent {
  final String exactDate;
  GetContributeHistoryYear({required this.exactDate});
}

class GetContributeHistoryMonth extends PartnersEvent {
  final String exactDate;
  GetContributeHistoryMonth({required this.exactDate});
}
