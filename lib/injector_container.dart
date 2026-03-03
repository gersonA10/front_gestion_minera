import 'package:front_gestion_minera/config/router/app_router.dart';
import 'package:front_gestion_minera/modules/auth/auth_container.dart';
import 'package:get_it/get_it.dart';

class InjectorContainer {
  InjectorContainer();

  static final getIt = GetIt.instance;
  static setupGetIt() {
    getIt.registerSingleton<AppRouter>(AppRouter());
    initAuthContainer(getIt);
  }
}
