part of 'minutes_memos_bloc.dart';

sealed class MinutesMemosEvent {}

class GetActasCountEvent extends MinutesMemosEvent {
  final String? filter;
  final String? from;
  final String? to;

  GetActasCountEvent({this.filter, this.from, this.to});
}

class GetMemosCountEvent extends MinutesMemosEvent {
  final String? filter;
  final String? from;
  final String? to;

  GetMemosCountEvent({this.filter, this.from, this.to});
}

class GetMemorandosEvent extends MinutesMemosEvent {
  final String? filter;
  final String? from;
  final String? to;
  final int page;
  final int limit;

  GetMemorandosEvent({
    this.filter,
    this.from,
    this.to,
    this.page = 1,
    this.limit = 10,
  });
}

class LoadMoreActasEvent extends MinutesMemosEvent {}

class LoadMoreMemorandosEvent extends MinutesMemosEvent {}

class GetActasEvent extends MinutesMemosEvent {
  final String? filter;
  final String? from;
  final String? to;
  final int page;
  final int limit;

  GetActasEvent({
    this.filter,
    this.from,
    this.to,
    this.page = 1,
    this.limit = 10,
  });
}

class SubmitCreateActaEvent extends MinutesMemosEvent {
  final CreateActaEntity actaResponse;
  
  SubmitCreateActaEvent({required this.actaResponse});
}

class SubmitCreateMemorandumEvent extends MinutesMemosEvent {
  final CreateMemorandumEntity memorandumResponse;

  SubmitCreateMemorandumEvent({required this.memorandumResponse});
}