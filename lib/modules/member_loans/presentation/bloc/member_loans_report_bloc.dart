import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/member_loans_error.dart';
import '../../domain/entity/member_loan_report_entity.dart';
import '../../domain/repositories/member_loans_repository.dart';

// ─── Eventos ─────────────────────────────────────────────────────────────────

sealed class MemberLoansReportEvent {}

class MemberLoansReportFetch extends MemberLoansReportEvent {
  final String? period;
  final String? exactDate;
  MemberLoansReportFetch({this.period, this.exactDate});
}

// ─── Estados ─────────────────────────────────────────────────────────────────

sealed class MemberLoansReportState {}

class MemberLoansReportLoading extends MemberLoansReportState {}

class MemberLoansReportError extends MemberLoansReportState {
  final String message;
  MemberLoansReportError(this.message);
}

class MemberLoansReportLoaded extends MemberLoansReportState {
  final MemberLoanReportEntity report;
  MemberLoansReportLoaded(this.report);
}

// ─── Bloc ────────────────────────────────────────────────────────────────────

class MemberLoansReportBloc
    extends Bloc<MemberLoansReportEvent, MemberLoansReportState> {
  final MemberLoansRepository repository;

  MemberLoansReportBloc({required this.repository})
      : super(MemberLoansReportLoading()) {
    on<MemberLoansReportFetch>(_onFetch);
  }

  Future<void> _onFetch(
    MemberLoansReportFetch event,
    Emitter<MemberLoansReportState> emit,
  ) async {
    emit(MemberLoansReportLoading());
    try {
      final report = await repository.getReport(
        period: event.period,
        exactDate: event.exactDate,
      );
      emit(MemberLoansReportLoaded(report));
    } catch (e) {
      emit(MemberLoansReportError(memberLoansError(e)));
    }
  }
}
