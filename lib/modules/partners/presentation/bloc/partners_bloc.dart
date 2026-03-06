
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/networking/base_api_exception.dart';
import 'package:front_gestion_minera/modules/partners/domain/entity/money_request_entity.dart';
import 'package:front_gestion_minera/modules/partners/domain/repositories/money_request_repository.dart';

part 'partners_event.dart';
part 'partners_state.dart';

class PartnersBloc extends Bloc<PartnersEvent, PartnersState> {
  final MoneyRequestRepository repository;
  PartnersBloc({required this.repository}) : super(PartnersInitial()) {
    
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

      if ( event.evidenceUrlPath.isEmpty ) {
        emit(PartnersMoneyRequestError('El Comprobante es obligatorio.'));
        return;
      } 

      final requestEntity = MoneyRequestEntity(
        area: event.area, 
        requestedAmount: event.requestedAmount, 
        description: event.description, 
        evidenceUrlPath: event.evidenceUrlPath
      );

      await repository.submitMoneyRequest(requestEntity);

      emit(PartnersMoneyRequestSuccess());
    } on BaseApiException catch (error){
       switch (error.key) {
        case "dio_unexpected":
        case "dio_connect_timeout":
          emit(PartnersMoneyRequestError('Ocurrió un error al enviar la solicitud de egreso.'));
          break;
        default:
          emit(PartnersMoneyRequestError('Ocurrió un error al enviar la solicitud de egreso.'));
      }
    }
  }
}