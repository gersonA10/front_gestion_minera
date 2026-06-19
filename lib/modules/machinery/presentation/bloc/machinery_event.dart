part of 'machinery_bloc.dart';

abstract class MachineryEvent {}

class FetchMetricsMachineEvent extends MachineryEvent {}

class ListInventoryMachineryEvent extends MachineryEvent {
  final bool isRefresh;
  final String? search;
  final String? status;
  final String? type;

  ListInventoryMachineryEvent({this.search, this.status, this.type,this.isRefresh = true});
}
class LoadMoreListInventoryMachineryEvent extends MachineryEvent {
  final bool isRefresh;

  LoadMoreListInventoryMachineryEvent({this.isRefresh = true});
}
class ListTypeMachinery extends MachineryEvent{
  final bool isRefresh;

  ListTypeMachinery({this.isRefresh = true});
}

class FetchMaintenanceHistoryEvent extends MachineryEvent {
  final String machineId;
  final bool isRefresh;

  FetchMaintenanceHistoryEvent({required this.machineId, this.isRefresh = true});
}

class LoadMoreMaintenanceHistoryEvent extends MachineryEvent {
  final String machineId;

  LoadMoreMaintenanceHistoryEvent({required this.machineId});
}

class RegisterMachineryEvent extends MachineryEvent {
  final RegisterMachineryRequestEntity request;

  RegisterMachineryEvent({required this.request});
}

class FetchDetailMaintenanceEvent extends MachineryEvent {
  final String machineId;

  FetchDetailMaintenanceEvent({required this.machineId});
}

class CreateMaintenanceRequestEvent extends MachineryEvent {
  final CreateMaintenanceRequestEntity request;
  CreateMaintenanceRequestEvent({
    required this.request
  });
}

class FetchFailureTypesEvent extends MachineryEvent {}

class GetCloseUpOfAMachineEvent extends MachineryEvent {
  final String machineId;
  final bool isRefresh;
  GetCloseUpOfAMachineEvent({required this.machineId, this.isRefresh = true});
}

class LoadMoreCloseUpOfAMachineEvent extends MachineryEvent {
  final String machineId;
  LoadMoreCloseUpOfAMachineEvent({required this.machineId});
}

class UpdateMachineryEvent extends MachineryEvent {
  final UpdateMachineryRequestEntity request;
  UpdateMachineryEvent({required this.request});
}

class ChangeMachineryStatusEvent extends MachineryEvent {
  final String machineId;
  final String status;
  ChangeMachineryStatusEvent({required this.machineId, required this.status});
}