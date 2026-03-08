import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/networking/base_api_exception.dart';
import 'package:front_gestion_minera/utils/error.dart';
import 'package:front_gestion_minera/modules/partners/domain/entity/money_request_entity.dart';
import 'package:front_gestion_minera/modules/partners/domain/entity/request_history_entity.dart';
import 'package:front_gestion_minera/modules/partners/domain/repositories/money_request_repository.dart';

import '../../domain/entity/entity.dart';
import '../../domain/repositories/repository.dart';
part 'partners_event.dart';
part 'partners_state.dart';

class PartnersBloc extends Bloc<PartnersEvent, PartnersState> {
  PartnersRepository repository;
  final MoneyRequestRepository moneyRepository;
  final LoanHistoryRepository loanHistoryRepository;

  int _currentPage = 1;
  bool _hasReachedMax = false;
  List<RequestHistoryEntity> _currentHistory = [];
  String? _currentStatus;
  String? _currentSearch;

  PartnersBloc({
    required this.repository,
    required this.moneyRepository,
    required this.loanHistoryRepository,
  }) : super(ContributeHistoryInitial()) {
    on<GetContributeHistory>(_getContributeHistory);
    on<GetContributeHistoryWeek>(_getContributeHistoryWeek);
    on<GetContributeHistoryMonth>(_getcontributeHistoryMonth);
    on<GetContributeHistoryYear>(_getContributeHistoryYear);

    on<PartnersSubmitMoneyRequestEvent>(_onSubmitMoneyRequest);
    on<GetRequestHistoryEvent>(_onGetRequestHistory);
    on<LoadMoreRequestHistoryEvent>(_onLoadMoreHistory);

    on<LoanHistoryRequestEvent>(_onLoanHistoryRequest);
    on<LoanHistoryStatusRequestEvent>(_onLoanHistoryStatusRequest);
  }
  Future<void> _getContributeHistory(
    GetContributeHistory event,
    Emitter<PartnersState> emit,
  ) async {
    emit(ContributeHistoryLoading());
    try {
      final response = await repository.getcontributeHistory();
      emit(ContributeHistorySuccess(response));
    } on BaseApiException catch (error) {
      emit(ContributeHistoryError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(ContributeHistoryError('Error inesperado: $e'));
    }
  }

  Future<void> _getContributeHistoryWeek(
    GetContributeHistoryWeek event,
    Emitter<PartnersState> emit,
  ) async {
    emit(ContributeHistoryLoading());
    try {
      final response = await repository.getcontributeHistoryWeek();
      emit(ContributeHistorySuccess(response));
    } on BaseApiException catch (error) {
      emit(ContributeHistoryError(mapErrorMessage(error.key)));
    }
  }

  Future<void> _getcontributeHistoryMonth(
    GetContributeHistoryMonth event,
    Emitter<PartnersState> emit,
  ) async {
    emit(ContributeHistoryLoading());
    try {
      final response = await repository.getcontributeHistoryMonth(
        event.exactDate,
      );
      emit(ContributeHistorySuccess(response));
    } on BaseApiException catch (error) {
      emit(ContributeHistoryError(mapErrorMessage(error.key)));
    }
  }

  Future<void> _getContributeHistoryYear(
    GetContributeHistoryYear event,
    Emitter<PartnersState> emit,
  ) async {
    emit(ContributeHistoryLoading());
    try {
      final response = await repository.getcontributeHistoryYear(
        event.exactDate,
      );
      emit(ContributeHistorySuccess(response));
    } on BaseApiException catch (error) {
      emit(ContributeHistoryError(mapErrorMessage(error.key)));
    }
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

      await moneyRepository.submitMoneyRequest(requestEntity);

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
      final paginatedData = await moneyRepository.getHistory(
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
      final paginatedData = await moneyRepository.getHistory(
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

  Future<void> _onLoanHistoryRequest(
    LoanHistoryRequestEvent event,
    Emitter<PartnersState> emit,
  ) async {
    emit(LoanHistoryLoading());
    try {
      final response = await loanHistoryRepository.getLoanHistory();
      emit(LoanHistorySuccess(response));
    } on BaseApiException catch (error) {
      emit(LoanHistoryError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(LoanHistoryError('Error inesperado: $e'));
    }
  }

  Future<void> _onLoanHistoryStatusRequest(
    LoanHistoryStatusRequestEvent event,
    Emitter<PartnersState> emit,
  ) async {
    emit(LoanHistoryStatusLoading());
    try {
      final response = await loanHistoryRepository.getLoanHistoryStatus(
        event.status,
      );
      emit(LoanHistoryStatusSuccess(response));
    } on BaseApiException catch (error) {
      emit(LoanHistoryStatusError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(LoanHistoryStatusError('Error inesperado: $e'));
    }
  }
}
