
import 'package:flutter_bloc/flutter_bloc.dart';

part 'partners_event.dart';
part 'partners_state.dart';

class PartnersBloc extends Bloc<PartnersEvent, PartnersState> {
  PartnersBloc() : super(PartnersInitial()) {
    
    // Handler para eventos iniciales o futuros
    on<PartnersEvent>((event, emit) {
      // TODO: implement event handler
    });

    // Manejador para la solicitud de dinero
    on<PartnersSubmitMoneyRequestEvent>(_onSubmitMoneyRequest);
  }

  Future<void> _onSubmitMoneyRequest(
    PartnersSubmitMoneyRequestEvent event, 
    Emitter<PartnersState> emit
  ) async {
    emit(PartnersMoneyRequestLoading());
    try {
      // TODO: Aquí ira el repositorio
      
      await Future.delayed(const Duration(seconds: 2));
      
      emit(PartnersMoneyRequestSuccess());
    } catch (e) {
      emit(PartnersMoneyRequestError('Ocurrió un error al enviar la solicitud de egreso.'));
    }
  }
}