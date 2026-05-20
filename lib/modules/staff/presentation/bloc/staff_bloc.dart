import 'package:bloc/bloc.dart';
import 'package:front_gestion_minera/modules/staff/domain/repositories/staff_repository.dart';
import 'package:meta/meta.dart';

part 'staff_event.dart';
part 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final StaffRepository repository;
  StaffBloc({required this.repository}) : super(StaffInitial()) {
    on<StaffEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
