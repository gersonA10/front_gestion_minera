import 'package:front_gestion_minera/config/router/app_router.dart';
import 'package:front_gestion_minera/modules/auth/auth_container.dart';
// IMPORTANTE: Debes importar el archivo de tu ApiClient
import 'package:front_gestion_minera/core/networking/http_services.dart'; 
import 'package:get_it/get_it.dart';

class InjectorContainer {
  InjectorContainer();

  static final getIt = GetIt.instance;

  static void setupGetIt() {
    getIt.registerSingleton<AppRouter>(AppRouter());
    
    // Registrar el ApiClient para que los datasources puedan usarlo
    getIt.registerLazySingleton<ApiClient>(() => ApiClient());

    initAuthContainer(getIt);
  }
}