import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/utils/error.dart';
import '../../../../core/networking/base_api_exception.dart';
import '../../domain/entity/entity.dart';
import '../../domain/repositories/treasury_repository.dart';

part 'treasury_event.dart';
part 'treasury_state.dart';

class TreasuryBloc extends Bloc<TreasuryEvent, TreasuryState> {
  final TreasuryRepository repository;

  TreasuryBloc({required this.repository}) : super(TreasuryInitial()) {
    on<FetchTreasuryMetricsEvent>(_onFetchTreasuryMetrics);
    on<DashboardDataEvent>(_dashboardData);
    on<DetailsofanapplicationEvent>(_getDetailsofanapplication);
  }

  Future<void> _onFetchTreasuryMetrics(
    FetchTreasuryMetricsEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    emit(TreasuryMetricsLoading());
    try {
      final metrics = await repository.getMetrics();
      emit(TreasuryMetricsLoaded(metrics: metrics));
    } on BaseApiException catch (error) {
      emit(TreasuryMetricsError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(TreasuryMetricsError('Error inesperado: $e'));
    }
  }

  Future<void> _dashboardData(
    DashboardDataEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    emit(DashboardDataLoading());
    try {
      final responseBalance = await repository.getBondBalence();
      final responsePending = await repository.getPendingApplications();
      emit(DashboardDataLoaded(bondBalance: responseBalance, pendingApplicationsResponseEntity: responsePending));
    } on BaseApiException catch (error) {
      emit(DashboardDataError(message: mapErrorMessage(error.key)));
    } catch (e) {
      emit(DashboardDataError(message:'Error inesperado: $e'));
    }
  }

  Future<void> _getDetailsofanapplication(
    DetailsofanapplicationEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    emit(DetailsofanapplicationLoading());
    try {
      final response = await repository.getDetailsofanapplication(event.id);
      final responseCash = await repository.getCash();
      emit(DetailsofanapplicationSuccess(data: response.data, cash: responseCash));
    } on BaseApiException catch (error) {
      emit(DetailsofanapplicationError(message:  mapErrorMessage(error.key)));
    } catch (e) {
      emit(DetailsofanapplicationError(message:  'Error inesperado: $e'));
    }
  }
}
