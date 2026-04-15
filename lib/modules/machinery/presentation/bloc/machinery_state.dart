part of 'machinery_bloc.dart';

abstract class MachineryState {}

class MachineryInitial extends MachineryState {}


class MetricsMachineryLoading extends MachineryState{}

class MetricsMachineryLoaded extends MachineryState {
  final MetricsMachineryEntity metrics;

  MetricsMachineryLoaded({required this.metrics});
}

class MetricsMachineryError extends MachineryState{
  final String message;

  MetricsMachineryError(this.message);
}
