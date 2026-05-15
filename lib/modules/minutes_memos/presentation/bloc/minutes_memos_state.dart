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

class CreateActasLoading extends MinutesMemosState {}

class CreateActasSucces extends MinutesMemosState {}

class CreateActasError extends MinutesMemosState {
  final String message;
  CreateActasError(this.message);
}

class CreateMemorandumLoading extends MinutesMemosState {}

class CreateMemorandumSucces extends MinutesMemosState {}

class CreateMemorandumError extends MinutesMemosState {
  final String message;
  CreateMemorandumError(this.message);
}

class MemorandumDetailLoading extends MinutesMemosState {}

class MemorandumDetailLoaded extends MinutesMemosState {
  final MemorandumDetailEntity memorandum;

  MemorandumDetailLoaded(this.memorandum);
}

class MemorandumDetailError extends MinutesMemosState {
  final String message;

  MemorandumDetailError(this.message);
}