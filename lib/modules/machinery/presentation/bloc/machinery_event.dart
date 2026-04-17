part of 'machinery_bloc.dart';

abstract class MachineryEvent {}

class FetchMetricsMachineEvent extends MachineryEvent {}

class ListInventoryMachineryEvent extends MachineryEvent {
  final bool isRefresh;

  ListInventoryMachineryEvent({this.isRefresh = true});
}