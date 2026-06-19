import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/member_loans_error.dart';
import '../../domain/entity/member_loan_list_entity.dart';
import '../../domain/repositories/member_loans_repository.dart';

// ─── Eventos ─────────────────────────────────────────────────────────────────

sealed class MemberLoansListEvent {}

class MemberLoansFetch extends MemberLoansListEvent {
  final String? status; // pendientes|vigentes|pagados|rechazados|cancelados
  final String? loanType; // dinero|gramos
  final String? search;
  final String? period;
  final String? exactDate;

  MemberLoansFetch({
    this.status,
    this.loanType,
    this.search,
    this.period,
    this.exactDate,
  });
}

class MemberLoansLoadMore extends MemberLoansListEvent {}

// ─── Estados ─────────────────────────────────────────────────────────────────

sealed class MemberLoansListState {}

class MemberLoansListInitial extends MemberLoansListState {}

class MemberLoansListLoading extends MemberLoansListState {}

class MemberLoansListError extends MemberLoansListState {
  final String message;
  MemberLoansListError(this.message);
}

class MemberLoansListLoaded extends MemberLoansListState {
  final List<MemberLoanListItemEntity> items;
  final bool hasReachedMax;
  final int totalRecords;
  MemberLoansListLoaded({
    required this.items,
    required this.hasReachedMax,
    required this.totalRecords,
  });
}

// ─── Bloc ────────────────────────────────────────────────────────────────────

class MemberLoansListBloc
    extends Bloc<MemberLoansListEvent, MemberLoansListState> {
  final MemberLoansRepository repository;

  int _page = 1;
  bool _reachedMax = false;
  bool _loadingMore = false;
  List<MemberLoanListItemEntity> _items = [];
  int _total = 0;
  String? _status;
  String? _loanType;
  String? _search;
  String? _period;
  String? _exactDate;

  MemberLoansListBloc({required this.repository})
      : super(MemberLoansListInitial()) {
    on<MemberLoansFetch>(_onFetch);
    on<MemberLoansLoadMore>(_onLoadMore);
  }

  Future<void> _onFetch(
    MemberLoansFetch event,
    Emitter<MemberLoansListState> emit,
  ) async {
    _status = event.status;
    _loanType = event.loanType;
    _search = event.search;
    _period = event.period;
    _exactDate = event.exactDate;
    _page = 1;
    _reachedMax = false;
    _loadingMore = false;

    emit(MemberLoansListLoading());
    try {
      final page = await repository.getLoans(
        status: _status,
        loanType: _loanType,
        search: _search,
        period: _period,
        exactDate: _exactDate,
        page: 1,
        limit: 10,
      );
      _items = page.items;
      _reachedMax = !page.hasMore;
      _total = page.totalRecords;
      emit(MemberLoansListLoaded(
        items: List.of(_items),
        hasReachedMax: _reachedMax,
        totalRecords: _total,
      ));
    } catch (e) {
      emit(MemberLoansListError(memberLoansError(e)));
    }
  }

  Future<void> _onLoadMore(
    MemberLoansLoadMore event,
    Emitter<MemberLoansListState> emit,
  ) async {
    if (_loadingMore || _reachedMax) return;
    _loadingMore = true;
    try {
      final next = _page + 1;
      final page = await repository.getLoans(
        status: _status,
        loanType: _loanType,
        search: _search,
        period: _period,
        exactDate: _exactDate,
        page: next,
        limit: 10,
      );
      _page = next;
      _items = [..._items, ...page.items];
      _reachedMax = !page.hasMore;
      emit(MemberLoansListLoaded(
        items: List.of(_items),
        hasReachedMax: _reachedMax,
        totalRecords: _total,
      ));
    } catch (_) {
      // Mantenemos lo cargado si falla la página siguiente.
    } finally {
      _loadingMore = false;
    }
  }
}
