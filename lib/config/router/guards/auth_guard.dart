import 'package:auto_route/auto_route.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final token = await UserSession.getAccessToken();

    //Se valida que si no hay token el user puda entraral login
    if (token.isEmpty) {
      resolver.next(true);
      return;
    }

    //Ahora aca si hay tken no se tiene que mostrar el login, y se va redirigir por rol
    final role = await UserSession.getRole();

    switch (role) {
      case 'hacienda':
        router.replaceAll([const TreasuryRoute()]);
      case 'socios':
        router.replaceAll([PartnersRoute(nombre: '')]);
      case 'vigilancia':
        router.replaceAll([const HomeSurveillanceRoute()]);
      case 'admin':
        router.replaceAll([const AdminHomeRoute()]);
       case 'jefe_maquinas':
        router.replaceAll([const HomeMachinaryRoute()]);
      
    default: 
       await UserSession.clear();
       router.replaceAll([AuthRoute()]);
       return;
    }
  }
}
