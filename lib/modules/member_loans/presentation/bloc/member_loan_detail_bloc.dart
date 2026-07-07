import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/member_loans_error.dart';
import '../../domain/entity/cash_register_entity.dart';
import '../../domain/entity/member_loan_detail_entity.dart';
import '../../domain/repositories/member_loans_repository.dart';

// ─── Eventos ─────────────────────────────────────────────────────────────────

sealed class MemberLoanDetailEvent {}

class MemberLoanDetailFetch extends MemberLoanDetailEvent {
  final String loanId;
  MemberLoanDetailFetch(this.loanId);
}

class MemberLoanApprove extends MemberLoanDetailEvent {
  final String loanId;
  final String? cashRegisterId;
  MemberLoanApprove(this.loanId, {this.cashRegisterId});
}

class MemberLoanReject extends MemberLoanDetailEvent {
  final String loanId;
  final String reason;
  MemberLoanReject(this.loanId, this.reason);
}

class MemberLoanCancel extends MemberLoanDetailEvent {
  final String loanId;
  final String reason;
  MemberLoanCancel(this.loanId, this.reason);
}

class MemberLoanRegisterPayment extends MemberLoanDetailEvent {
  final String loanId;
  final String paymentType; // INTEREST | PRINCIPAL
  final double? amount;
  final String? periodId;
  final String? cashRegisterId;
  final String? paidAt;
  final String? notes;
  final String? comprobantePath;

  MemberLoanRegisterPayment({
    required this.loanId,
    required this.paymentType,
    this.amount,
    this.periodId,
    this.cashRegisterId,
    this.paidAt,
    this.notes,
    this.comprobantePath,
  });
}

// ─── Estados ─────────────────────────────────────────────────────────────────

sealed class MemberLoanDetailState {}

class MemberLoanDetailLoading extends MemberLoanDetailState {}

class MemberLoanDetailError extends MemberLoanDetailState {
  final String message;
  MemberLoanDetailError(this.message);
}

class MemberLoanDetailLoaded extends MemberLoanDetailState {
  final MemberLoanDetailEntity detail;
  final List<CashRegisterEntity> cashRegisters;
  MemberLoanDetailLoaded({required this.detail, required this.cashRegisters});
}

/// Una acción (aprobar/rechazar/cancelar/pago) está en curso.
class MemberLoanActionInProgress extends MemberLoanDetailState {
  final MemberLoanDetailEntity detail;
  final List<CashRegisterEntity> cashRegisters;
  MemberLoanActionInProgress({
    required this.detail,
    required this.cashRegisters,
  });
}

/// La acción terminó OK (se mostrará y luego se recarga el detalle).
class MemberLoanActionSuccess extends MemberLoanDetailState {
  final String message;
  MemberLoanActionSuccess(this.message);
}

/// La acción falló; se vuelve a mostrar el detalle.
class MemberLoanActionError extends MemberLoanDetailState {
  final String message;
  final MemberLoanDetailEntity detail;
  final List<CashRegisterEntity> cashRegisters;
  MemberLoanActionError(
    this.message, {
    required this.detail,
    required this.cashRegisters,
  });
}

// ─── Bloc ────────────────────────────────────────────────────────────────────

class MemberLoanDetailBloc
    extends Bloc<MemberLoanDetailEvent, MemberLoanDetailState> {
  final MemberLoansRepository repository;

  MemberLoanDetailEntity? _detail;
  List<CashRegisterEntity> _cashRegisters = [];

  MemberLoanDetailBloc({required this.repository})
      : super(MemberLoanDetailLoading()) {
    on<MemberLoanDetailFetch>(_onFetch);
    on<MemberLoanApprove>(_onApprove);
    on<MemberLoanReject>(_onReject);
    on<MemberLoanCancel>(_onCancel);
    on<MemberLoanRegisterPayment>(_onPayment);
  }

  Future<void> _onFetch(
    MemberLoanDetailFetch event,
    Emitter<MemberLoanDetailState> emit,
  ) async {
    emit(MemberLoanDetailLoading());
    try {
      final detail = await repository.getDetail(event.loanId);
      // Cargamos cajas solo si hace falta (préstamo en dinero) y aún no están.
      if (detail.cabecera.tipo.toLowerCase() == 'dinero' &&
          _cashRegisters.isEmpty) {
        try {
          _cashRegisters = await repository.getCashRegisters();
        } catch (_) {
          _cashRegisters = [];
        }
      }
      _detail = detail;
      emit(MemberLoanDetailLoaded(
        detail: detail,
        cashRegisters: _cashRegisters,
      ));
    } catch (e) {
      emit(MemberLoanDetailError(memberLoansError(e)));
    }
  }

  Future<void> _runAction(
    Emitter<MemberLoanDetailState> emit,
    String loanId,
    Future<String> Function() action,
  ) async {
    final detail = _detail;
    if (detail == null) return;
    emit(MemberLoanActionInProgress(
      detail: detail,
      cashRegisters: _cashRegisters,
    ));
    try {
      final message = await action();
      emit(MemberLoanActionSuccess(message));
      // Recargamos el detalle para reflejar el nuevo estado.
      add(MemberLoanDetailFetch(loanId));
    } catch (e) {
      emit(MemberLoanActionError(
        memberLoansError(e),
        detail: detail,
        cashRegisters: _cashRegisters,
      ));
    }
  }

  Future<void> _onApprove(
    MemberLoanApprove event,
    Emitter<MemberLoanDetailState> emit,
  ) =>
      _runAction(
        emit,
        event.loanId,
        () => repository.approve(event.loanId,
            cashRegisterId: event.cashRegisterId),
      );

  Future<void> _onReject(
    MemberLoanReject event,
    Emitter<MemberLoanDetailState> emit,
  ) =>
      _runAction(
        emit,
        event.loanId,
        () => repository.reject(event.loanId, event.reason),
      );

  Future<void> _onCancel(
    MemberLoanCancel event,
    Emitter<MemberLoanDetailState> emit,
  ) =>
      _runAction(
        emit,
        event.loanId,
        () => repository.cancel(event.loanId, event.reason),
      );

  Future<void> _onPayment(
    MemberLoanRegisterPayment event,
    Emitter<MemberLoanDetailState> emit,
  ) =>
      _runAction(
        emit,
        event.loanId,
        () => repository.registerPayment(
          event.loanId,
          paymentType: event.paymentType,
          amount: event.amount,
          periodId: event.periodId,
          cashRegisterId: event.cashRegisterId,
          paidAt: event.paidAt,
          notes: event.notes,
          comprobantePath: event.comprobantePath,
        ),
      );
}
