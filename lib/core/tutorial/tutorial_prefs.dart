import 'package:shared_preferences/shared_preferences.dart';

/// Persistencia del estado de los tutoriales (coach marks) por rol.
///
/// Guarda en [SharedPreferences] si un rol ya vio su recorrido guiado, para
/// no mostrarlo automáticamente en cada ingreso. El recorrido siempre se puede
/// reabrir manualmente desde el botón de ayuda de cada pantalla.
///
/// Está pensado para reutilizarse en otros roles: basta con usar una clave de
/// rol distinta (p. ej. `'socios'`, `'admin'`, `'vigilancia'`).
class TutorialPrefs {
  const TutorialPrefs._();

  static String _prefKey(String roleKey) => 'TUTORIAL_SEEN_$roleKey';

  /// `true` si el [roleKey] ya completó/omitió su tutorial alguna vez.
  static Future<bool> hasSeen(String roleKey) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_prefKey(roleKey)) ?? false;
  }

  /// Marca el tutorial del [roleKey] como visto.
  static Future<void> markSeen(String roleKey) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_prefKey(roleKey), true);
  }

  /// Borra el flag del [roleKey] para que el tutorial vuelva a mostrarse solo.
  static Future<void> reset(String roleKey) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_prefKey(roleKey));
  }
}
