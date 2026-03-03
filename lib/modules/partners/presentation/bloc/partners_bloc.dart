import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'partners_event.dart';
part 'partners_state.dart';

class PartnersBloc extends Bloc<PartnersEvent, PartnersState> {
  PartnersBloc() : super(PartnersInitial()) {
    on<PartnersEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
