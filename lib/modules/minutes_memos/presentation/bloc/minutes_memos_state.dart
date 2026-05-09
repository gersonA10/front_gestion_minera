part of 'minutes_memos_bloc.dart';

sealed class MinutesMemosState {}

class MinutesMemosInitial extends MinutesMemosState {}

class ActasCountLoading extends MinutesMemosState {}

class ActasCountLoaded extends MinutesMemosState {
  final MemosCountEntity count;
  ActasCountLoaded(this.count);
}

class ActasCountError extends MinutesMemosState {
  final String message;
  ActasCountError(this.message);
}

class MemosCountLoading extends MinutesMemosState {}

class MemosCountLoaded extends MinutesMemosState {
  final MemosCountEntity count;
  MemosCountLoaded(this.count);
}

class MemosCountError extends MinutesMemosState {
  final String message;
  MemosCountError(this.message);
}

class MemorandosLoading extends MinutesMemosState {}

class MemorandosLoaded extends MinutesMemosState {
  final List<MemorandumEntity> items;
  final bool hasMore;
  MemorandosLoaded({required this.items, required this.hasMore});
}

class MemorandosError extends MinutesMemosState {
  final String message;
  MemorandosError(this.message);
}

class ActasLoading extends MinutesMemosState {}

class ActasLoaded extends MinutesMemosState {
  final List<ActaEntity> items;
  final bool hasMore;
  ActasLoaded({required this.items, required this.hasMore});
}

class ActasError extends MinutesMemosState {
  final String message;
  ActasError(this.message);
}
