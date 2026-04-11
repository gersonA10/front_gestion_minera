import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/networking/base_api_exception.dart';
import 'package:front_gestion_minera/utils/error.dart';

import '../../domain/repositories/users_repository.dart';
import '../../domain/entity/user_entity.dart';

part 'admin_users_event.dart';
part 'admin_users_state.dart';

class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState> {
  final UsersRepository repository;

  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasReachedMax = false;
  int _totalRecords = 0;
  String? _currentSearch;
  String _currentStatus = 'Todos';
  List<UserEntity> _users = [];

  AdminUsersBloc({required this.repository}) : super(AdminUsersInitial()) {
    on<GetUsersListEvent>(_onGetUsersList);
    on<LoadMoreUsersEvent>(_onLoadMoreUsers);
    on<ToggleUserStatusEvent>(_onToggleUserStatus);
    on<LoadFormDependenciesEvent>(_onLoadFormDependencies);
    on<SaveUserEvent>(_onSaveUser);
  }

  Future<void> _onGetUsersList(
    GetUsersListEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    if (event.isRefresh ||
        _currentSearch != event.search ||
        _currentStatus != event.status) {
      _currentPage = 1;
      _hasReachedMax = false;
      _users.clear();
      _currentSearch = event.search;
      _currentStatus = event.status;
      emit(UsersLoading());
    }

    try {
      final result = await repository.getUsers(
        page: _currentPage,
        search: _currentSearch,
        status: _currentStatus,
      );

      _users = result['items'];
      _hasReachedMax = !result['has_more_data'];
      _totalRecords = result['total_records'];

      emit(
        UsersLoaded(
          users: List.from(_users),
          hasReachedMax: _hasReachedMax,
          totalRecords: _totalRecords,
        ),
      );
    } on BaseApiException catch (e) {
      emit(UsersError(mapErrorMessage(e.key)));
    }
  }

  Future<void> _onLoadMoreUsers(
    LoadMoreUsersEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    if (_hasReachedMax || _isLoadingMore) return;
    _isLoadingMore = true;
    _currentPage++;

    try {
      final result = await repository.getUsers(
        page: _currentPage,
        search: _currentSearch,
        status: _currentStatus,
      );
      _users.addAll(result['items']);
      _hasReachedMax = !result['has_more_data'];
      emit(
        UsersLoaded(
          users: List.from(_users),
          hasReachedMax: _hasReachedMax,
          totalRecords: _totalRecords,
        ),
      );
    } catch (_) {
      _currentPage--;
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> _onToggleUserStatus(
    ToggleUserStatusEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(UserActionLoading());
    try {
      final payload = {
        "full_name": event.user.fullName,
        "role_id": event.user.roleId,
        "role_name": event.user.roleName,
        "is_active": !event.user.isActive,
        "identification": event.user.identification,
        "phone": event.user.phone,
        "password": "",
      };

      await repository.updateUser(event.user.id, payload);
      emit(UserActionSuccess('Estado del usuario actualizado'));
      add(
        GetUsersListEvent(
          search: _currentSearch,
          status: _currentStatus,
          isRefresh: true,
        ),
      ); // Recargar
    } on BaseApiException catch (e) {
      emit(UserActionError(mapErrorMessage(e.key)));
    }
  }

  Future<void> _onLoadFormDependencies(
    LoadFormDependenciesEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(UserActionLoading());
    try {
      final roles = await repository.getRoles();

      UserEntity? userDetail;
      if (event.userId != null) {
        userDetail = await repository.getUserDetail(event.userId!);
      }

      emit(FormDependenciesLoaded(roles: roles, userToEdit: userDetail));
    } on BaseApiException catch (e) {
      emit(UserActionError(mapErrorMessage(e.key)));
    }
  }

  Future<void> _onSaveUser(
    SaveUserEvent event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(UserActionLoading());
    try {
      if (event.userId == null) {
        await repository.createUser(event.userData);
        emit(UserActionSuccess('Usuario creado exitosamente'));
      } else {
        await repository.updateUser(event.userId!, event.userData);
        emit(UserActionSuccess('Usuario actualizado exitosamente'));
      }
    } on BaseApiException catch (e) {
      emit(UserActionError(mapErrorMessage(e.key)));
    }
  }
}
