import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.dart';
import 'package:front_gestion_minera/injector_container.dart';

import '../../../../config/router/app_router.gr.dart';
import '../../domain/entity/entity.dart';
import '../../domain/repositories/repository.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<AuthDataEvent>(authBloc);
  }
  Future<void> authBloc(AuthDataEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await repository.login(event.username, event.password);
      emit(AuthSuccess(response.data));
      if (response.data.roleName == 'hacienda') {
        InjectorContainer.getIt<AppRouter>().push(
          PartnersRoute(nombre: response.data.fullName),
        );
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
