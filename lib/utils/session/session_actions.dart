// ignore_for_file: use_build_context_synchronously
import 'package:front_gestion_minera/config/router/app_router.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';

enum SessionLogoutReason {
  /// El usuario cerró sesión manualmente
  manual,
  /// El timer de inactividad expiró
  inactivity,
  /// La sesión fue abierta en otro dispositivo y ésta fue desplazada
  replacedByAnotherDevice,
}

class SessionActions {
  static bool _isLoggingOut = false;

  static Future<void> logout([
    SessionLogoutReason reason = SessionLogoutReason.manual,
  ]) async {
    if (_isLoggingOut) return;

    _isLoggingOut = true;

    try {
      await UserSession.clear();
      final router = InjectorContainer.getIt<AppRouter>();

      await router.replaceAll([const AuthRoute()]);

      if (reason != SessionLogoutReason.manual) {
        final context = router.navigatorKey.currentContext;
        if (context != null) {
          final (title, message) = switch (reason) {
            SessionLogoutReason.replacedByAnotherDevice => (
                'Sesión Cerrada',
                'Tu cuenta fue iniciada en otro dispositivo. Inicia sesión de nuevo.',
              ),
            _ => (
                'Sesión Expirada',
                'Tu sesión expiró, inicia sesión de nuevo.',
              ),
          };

          Future.delayed(const Duration(milliseconds: 300), () {
            CustomAlert.show(
              context,
              title: title,
              message: message,
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