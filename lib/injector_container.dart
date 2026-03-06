import 'package:front_gestion_minera/config/router/app_router.dart';
import 'package:front_gestion_minera/config/router/guards/auth_guard.dart';
import 'package:front_gestion_minera/modules/auth/auth_container.dart';
import 'package:front_gestion_minera/core/networking/http_services.dart';
import 'package:front_gestion_minera/modules/partners/partners_container.dart';
import 'package:get_it/get_it.dart';

class InjectorContainer {
  InjectorContainer();

  static final getIt = GetIt.instance;

  static void setupGetIt() {
    getIt.registerLazySingleton<AuthGuard>(() => AuthGuard());
    getIt.registerLazySingleton<AppRouter>(() => AppRouter(getIt<AuthGuard>()));

    // Registrar el ApiClient para que los datasources puedan usarlo
    getIt.registerLazySingleton<ApiClient>(() => ApiClient());

    initAuthContainer(getIt);
    initPartnersContainer(getIt);
  }
}
