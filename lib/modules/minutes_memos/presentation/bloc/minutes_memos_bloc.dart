import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/networking/base_api_exception.dart';
import 'package:front_gestion_minera/modules/minutes_memos/domain/entity/entity.dart';
import 'package:front_gestion_minera/utils/error.dart';

import '../../domain/repositories/minutes_memos_repository.dart';

part 'minutes_memos_event.dart';
part 'minutes_memos_state.dart';

class MinutesMemosBloc extends Bloc<MinutesMemosEvent, MinutesMemosState> {
  final MinutesMemosRepository repository;

  int _actasPage = 1;
  bool _actasHasMore = false;
  List<ActaEntity> _actasItems = [];
  bool _isActasLoadingMore = false;
  String? _actasFilter;
  String? _actasFrom;
  String? _actasTo;

  int _memosPage = 1;
  bool _memosHasMore = false;
  List<MemorandumEntity> _memosItems = [];
  bool _isMemosLoadingMore = false;
  String? _memosFilter;
  String? _memosFrom;
  String? _memosTo;

  MinutesMemosBloc({required this.repository}) : super(MinutesMemosInitial()) {
    on<GetActasCountEvent>(_onGetActasCount);
    on<GetMemosCountEvent>(_onGetMemosCount);
    on<GetMemorandosEvent>(_onGetMemorandos);
    on<LoadMoreMemorandosEvent>(_onLoadMoreMemorandos);
    on<GetActasEvent>(_onGetActas);
    on<LoadMoreActasEvent>(_onLoadMoreActas);
    on<SubmitCreateMemorandumEvent>(_onSubmitCreateMemorandum);
    on<SubmitCreateActaEvent>(_onSubmitCreateActa);
  }

  Future<void> _onGetActasCount(
    GetActasCountEvent event,
    Emitter<MinutesMemosState> emit,
  ) async {
    emit(ActasCountLoading());
    try {
      final count = await repository.getActasCount(
        filter: event.filter,
        from: event.from,
        to: event.to,
      );
      emit(ActasCountLoaded(count));
    } on BaseApiException catch (e) {
      emit(ActasCountError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(ActasCountError('Ocurrió un error inesperado'));
    }
  }

  Future<void> _onGetMemosCount(
    GetMemosCountEvent event,
    Emitter<MinutesMemosState> emit,
  ) async {
    emit(MemosCountLoading());
    try {
      final count = await repository.getMemosCount(
        filter: event.filter,
        from: event.from,
        to: event.to,
      );
      emit(MemosCountLoaded(count));
    } on BaseApiException catch (e) {
      emit(MemosCountError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(MemosCountError('Ocurrió un error inesperado'));
    }
  }

  Future<void> _onGetMemorandos(
    GetMemorandosEvent event,
    Emitter<MinutesMemosState> emit,
  ) async {
    _memosPage = 1;
    _memosHasMore = false;
    _memosItems = [];
    _memosFilter = event.filter;
    _memosFrom = event.from;
    _memosTo = event.to;
    emit(MemorandosLoading());
    try {
      final list = await repository.getMemorandos(
        filter: event.filter,
        from: event.from,
        to: event.to,
        page: 1,
        limit: event.limit,
      );
      _memosItems = List.from(list.items);
      _memosHasMore = list.hasMoreData;
      emit(
        MemorandosLoaded(items: List.from(_memosItems), hasMore: _memosHasMore),
      );
    } on BaseApiException catch (e) {
      emit(MemorandosError(mapErrorMessage(e.key)));
    } catch (e) {
      emit(MemorandosError('Error: ${e.runtimeType} — $e'));
    }
  }

  Future<void> _onLoadMoreMemorandos(
    LoadMoreMemorandosEvent event,
    Emitter<MinutesMemosState> emit,
  ) async {
    if (!_memosHasMore || _isMemosLoadingMore) return;
    _isMemosLoadingMore = true;
    _memosPage++;
    try {
      final list = await repository.getMemorandos(
        filter: _memosFilter,
        from: _memosFrom,
        to: _memosTo,
        page: _memosPage,
        limit: 10,
      );
      _memosItems.addAll(list.items);
      _memosHasMore = list.hasMoreData;
      emit(
        MemorandosLoaded(items: List.from(_memosItems), hasMore: _memosHasMore),
      );
    } on BaseApiException catch (e) {
      _memosPage--;
      emit(MemorandosError(mapErrorMessage(e.key)));
    } catch (_) {
      _memosPage--;
      emit(MemorandosError('Ocurrió un error inesperado'));
    } finally {
      _isMemosLoadingMore = false;
    }
  }

  Future<void> _onGetActas(
    GetActasEvent event,
    Emitter<MinutesMemosState> emit,
  ) async {
    _actasPage = 1;
    _actasHasMore = false;
    _actasItems = [];
    _actasFilter = event.filter;
    _actasFrom = event.from;
    _actasTo = event.to;
    emit(ActasLoading());
    try {
      final list = await repository.getActas(
        filter: event.filter,
        from: event.from,
        to: event.to,
        page: 1,
        limit: event.limit,
      );
      _actasItems = List.from(list.items);
      _actasHasMore = list.hasMore;
      emit(ActasLoaded(items: List.from(_actasItems), hasMore: _actasHasMore));
    } on BaseApiException catch (e) {
      emit(ActasError(mapErrorMessage(e.key)));
    } catch (_) {
      emit(ActasError('Ocurrió un error inesperado'));
    }
  }

  Future<void> _onLoadMoreActas(
    LoadMoreActasEvent event,
    Emitter<MinutesMemosState> emit,
  ) async {
    if (!_actasHasMore || _isActasLoadingMore) return;
    _isActasLoadingMore = true;
    _actasPage++;
    try {
      final list = await repository.getActas(
        filter: _actasFilter,
        from: _actasFrom,
        to: _actasTo,
        page: _actasPage,
        limit: 10,
      );
      _actasItems.addAll(list.items);
      _actasHasMore = list.hasMore;
      emit(ActasLoaded(items: List.from(_actasItems), hasMore: _actasHasMore));
    } on BaseApiException catch (e) {
      _actasPage--;
      emit(ActasError(mapErrorMessage(e.key)));
    } catch (_) {
      _actasPage--;
      emit(ActasError('Ocurrió un error inesperado'));
    } finally {
      _isActasLoadingMore = false;
    }
  }

  FutureOr<void> _onSubmitCreateMemorandum(
    SubmitCreateMemorandumEvent event,
    Emitter<MinutesMemosState> emit,
  ) async {
    emit(MemorandosLoading());
    try {
      await repository.createMemorandum(event.memorandumResponse);
      emit(CreateMemorandumSucces());
    } on BaseApiException catch (error) {
      emit(CreateMemorandumError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(CreateMemorandumError('Error inesperado: $e'));
    }
  }

  FutureOr<void> _onSubmitCreateActa(
    SubmitCreateActaEvent event,
    Emitter<MinutesMemosState> emit,
  ) async{
    emit (MemorandosLoading());
    try {
      await repository.createActa(event.actaResponse);
      emit(CreateActasSucces());
    } on BaseApiException catch (error) {
      emit(CreateActasError(mapErrorMessage(error.key)));
    } catch (e) {
      emit(CreateActasError('Error inesperado: $e'));
    }
  }
}
