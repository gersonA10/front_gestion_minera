import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'staff_event.dart';
part 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  StaffBloc() : super(StaffInitial());

  @override
  Stream<StaffState> mapEventToState(
    StaffEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
