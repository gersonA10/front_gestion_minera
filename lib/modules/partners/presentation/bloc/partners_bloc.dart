import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/networking/base_api_exception.dart';
import 'package:front_gestion_minera/modules/partners/domain/entity/money_request_entity.dart';
import 'package:front_gestion_minera/modules/partners/domain/entity/request_history_entity.dart';
import 'package:front_gestion_minera/modules/partners/domain/repositories/money_request_repository.dart';

part 'partners_event.dart';
part 'partners_state.dart';

class PartnersBloc extends Bloc<PartnersEvent, PartnersState> {
  final MoneyRequestRepository repository;

  int _currentPage = 1;
  bool _hasReachedMax = false;
  List<RequestHistoryEntity> _currentHistory = [];
  String? _currentStatus;
  String? _currentSearch;

  PartnersBloc({required this.repository}) : super(PartnersInitial()) {
    on<LoadMoreRequestHistoryEvent>(_onLoadMoreHistory);
    on<GetRequestHistoryEvent>(_onGetRequestHistory);
    // Manejador para la solicitud de dinero
    on<PartnersSubmitMoneyRequestEvent>(_onSubmitMoneyRequest);
  }

  Future<void> _onSubmitMoneyRequest(
    PartnersSubmitMoneyRequestEvent event,
    Emitter<PartnersState> emit,
  ) async {
    emit(PartnersMoneyRequestLoading());
    try {
      if (event.evidenceUrlPath.isEmpty) {
        emit(PartnersMoneyRequestError('El Comprobante es obligatorio.'));
        return;
      }

      final requestEntity = MoneyRequestEntity(
        area: event.area,
        requestedAmount: event.requestedAmount,
        description: event.description,
        evidenceUrlPath: event.evidenceUrlPath,
      );

      await repository.submitMoneyRequest(requestEntity);

      emit(PartnersMoneyRequestSuccess());
    } on BaseApiException catch (error) {
      switch (error.key) {
        case "dio_unexpected":
        case "dio_connect_timeout":
          emit(
            PartnersMoneyRequestError(
              'Ocurrió un error al enviar la solicitud de egreso.',
            ),
          );
          break;
        default:
          emit(
            PartnersMoneyRequestError(
              'Ocurrió un error al enviar la solicitud de egreso.',
            ),
          );
      }
    }
  }

  Future<void> _onGetRequestHistory(
    GetRequestHistoryEvent event,
    Emitter<PartnersState> emit,
  ) async {
    if (event.isRefresh) {
      _currentPage = 1;
      _hasReachedMax = false;
      _currentHistory.clear();
      emit(RequestHistoryLoading());
    }

    _currentStatus = event.status;
    _currentSearch = event.search;

    try {
      final paginatedData = await repository.getHistory(
        status: _currentStatus,
        search: _currentSearch,
        page: _currentPage,
      );

      _currentHistory = paginatedData.items;
      _hasReachedMax = !paginatedData.hasMoreData;

      emit(
        RequestHistoryLoaded(
          history: List.from(_currentHistory),
          hasReachedMax: _hasReachedMax,
        ),
      );
    } on BaseApiException catch (_) {
      emit(RequestHistoryError('Ocurrió un error al cargar el historial.'));
    } catch (e) {
      emit(RequestHistoryError('Error inesperado al cargar datos.'));
    }
  }

  Future<void> _onLoadMoreHistory(
    LoadMoreRequestHistoryEvent event,
    Emitter<PartnersState> emit,
  ) async {
    if (_hasReachedMax || state is! RequestHistoryLoaded) return;

    _currentPage++;
    try {
      final paginatedData = await repository.getHistory(
        status: _currentStatus,
        search: _currentSearch,
        page: _currentPage,
      );

      _currentHistory.addAll(paginatedData.items);
      _hasReachedMax = !paginatedData.hasMoreData;

      emit(
        RequestHistoryLoaded(
          history: List.from(_currentHistory),
          hasReachedMax: _hasReachedMax,
        ),
      );
    } on BaseApiException catch (_) {
      emit(RequestHistoryError('Ocurrió un error al cargar el historial.'));
    } 
  }
}
