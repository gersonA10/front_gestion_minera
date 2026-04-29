part of 'machinery_bloc.dart';

abstract class MachineryState {}

class MachineryInitial extends MachineryState {}

class MetricsMachineryLoading extends MachineryState {}

class MetricsMachineryLoaded extends MachineryState {
  final MetricsMachineryEntity metrics;

  MetricsMachineryLoaded({required this.metrics});
}

class MetricsMachineryError extends MachineryState {
  final String message;

  MetricsMachineryError(this.message);
}

class InventoryMachineryLoading extends MachineryState {}

class InventoryMachineryLoaded extends MachineryState {
  final List<MachineryEntity> machinery;
  final bool hasReachedMax;
  final int totalRecords;
  final String? search;
  final String? status;
  final String? type;
  InventoryMachineryLoaded({
    required this.machinery,
    required this.hasReachedMax,
    required this.totalRecords,
    this.search,
    this.status,
    this.type,
  });
}

class InventoryMachineryError extends MachineryState {
  final String message;

  InventoryMachineryError(this.message);
}

class TypeMachineryLoading extends MachineryState {}
class TypeMachineryLoaded extends MachineryState {
  final List<TypeMachineryEntity> types;

  TypeMachineryLoaded({required this.types});
}
class TypeMachineryError extends MachineryState {
  final String message;

  TypeMachineryError(this.message);
}

class MaintenanceHistoryLoading extends MachineryState {}

class MaintenanceHistoryLoaded extends MachineryState {
  final List<MaintenanceHistoryItemEntity> items;
  final bool hasReachedMax;
  final int totalRecords;

  MaintenanceHistoryLoaded({
    required this.items,
    required this.hasReachedMax,
    required this.totalRecords,
  });
}

class MaintenanceHistoryError extends MachineryState {
  final String message;

  MaintenanceHistoryError(this.message);
}

class RegisterMachineryLoading extends MachineryState {}

class RegisterMachinerySuccess extends MachineryState {
  final RegisterMachineryResponseEntity response;
  RegisterMachinerySuccess( {required this.response});
}

class RegisterMachineryError extends MachineryState {
  final String message;
  RegisterMachineryError(this.message);
}

//estados para detalle de mantenimiento
class DetailMaintenanceLoading extends MachineryState {}

class DetailMaintenanceLoaded extends MachineryState {
  final DetailMaintenanceResponseEntity detail;

  DetailMaintenanceLoaded({required this.detail});
}

class DetailMaintenanceError extends MachineryState {
  final String message;

  DetailMaintenanceError(this.message);
}


class CreateMaintenanceRequestLoading extends MachineryState {}

class CreateMaintenanceRequestSuccess extends MachineryState {
  final CreateMaintenanceResponseEntity response;
  CreateMaintenanceRequestSuccess({required this.response});
}

class CreateMaintenanceRequestError extends MachineryState {
  final String message;
  CreateMaintenanceRequestError(this.message);
}

class FailureTypesLoading extends MachineryState {}

class FailureTypesLoaded extends MachineryState {
  final List<FailureTypeEntity> failureTypes;
  FailureTypesLoaded({required this.failureTypes});
}

class FailureTypesError extends MachineryState {
  final String message;
  FailureTypesError(this.message);
}
///
class GetCloseUpOfAMachineLoading extends MachineryState {}

class GetCloseUpOfAMachineLoaded extends MachineryState {
  final HeaderMetricsEntity headerMetrics;
  final List<MaintenancesListEntity> items;
  final bool hasReachedMax;
  final int totalRecords;

  GetCloseUpOfAMachineLoaded({
    required this.headerMetrics,
    required this.items,
    required this.hasReachedMax,
    required this.totalRecords,
  });
}

class GetCloseUpOfAMachineError extends MachineryState {
  final String message;
  GetCloseUpOfAMachineError(this.message);
}