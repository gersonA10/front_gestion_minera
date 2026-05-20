part of 'staff_bloc.dart';

sealed class StaffState {}

class StaffInitial extends StaffState {}

class RegisterEmployeesLoading extends StaffState {}

class RegisterEmployeesSuccess extends StaffState {}

class RegisterEmployeesError extends StaffState {
  final String message;
  RegisterEmployeesError(this.message);
}