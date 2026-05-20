part of 'staff_bloc.dart';

sealed class StaffEvent {}

class RegisterEmployeesEvent extends StaffEvent {
  final RegisterEmployeesEntity employeed;

  RegisterEmployeesEvent({required this.employeed});
}
