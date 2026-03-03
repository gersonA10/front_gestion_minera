import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'treasury_event.dart';
part 'treasury_state.dart';

class TreasuryBloc extends Bloc<TreasuryEvent, TreasuryState> {
  TreasuryBloc() : super(TreasuryInitial()) {
    on<TreasuryEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
