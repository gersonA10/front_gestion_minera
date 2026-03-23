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
    on<GetFinancialReportEvent>(_onGetFinancialReportEvent);
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
      emit(DetailsofanapplicationSuccess(data: response.data));
    } on BaseApiException catch (error) {
      emit(DetailsofanapplicationError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(DetailsofanapplicationError('Error inesperado: $e'));
    }
  }


  Future<void> _onGetFinancialReportEvent(
    GetFinancialReportEvent event,
    Emitter<TreasuryState> emit,
  ) async {
    emit(FinancialReportLoading());
    
    try {
      final report = await repository.getFinancialReport(
        period: event.period,
        exactDate: event.exactDate,
      );
      
      emit(FinancialReportLoaded(report: report));
    } catch (e) {
      emit(FinancialReportError(message: 'Error al cargar el reporte: $e'));
    }
  }

}
