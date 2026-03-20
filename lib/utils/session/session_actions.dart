// ignore_for_file: use_build_context_synchronously
import 'package:front_gestion_minera/config/router/app_router.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';

class SessionActions {
  static bool _isLoggingOut = false;

  static Future<void> logout([bool showExpirationMessage = false]) async {
    if (_isLoggingOut) return; 
    
    _isLoggingOut = true;

    try {
      await UserSession.clear();
      final router = InjectorContainer.getIt<AppRouter>();
      
      await router.replaceAll([const AuthRoute()]);

      if (showExpirationMessage) {
        final context = router.navigatorKey.currentContext;
        if (context != null) {
          Future.delayed(const Duration(milliseconds: 300), () {
            CustomAlert.show(
              context,
              title: 'Sesión Expirada',
              message: 'Tu sesión expiró, inicia sesión de nuevo.',
              type: AlertType.warning,
            );
          });
        }
      }
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        _isLoggingOut = false;
      });
    }
  }
}