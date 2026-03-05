import 'package:front_gestion_minera/config/router/app_router.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';

class SessionActions {

  //Cerrar sesion
  static Future<void> logout() async {
    await UserSession.clear();
    final router = InjectorContainer.getIt<AppRouter>();
    router.replaceAll([const AuthRoute()]);
  }
}