import 'package:front_gestion_minera/modules/auth/domain/entity/auth_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static const String _idKey = 'ID';
  static const String _fullNameKey = 'FULLNAME';
  static const String _emailKey = 'EMAIL';
  static const String _roleKey = 'ROLE';
  static const String _accessTokenKey = 'TOKEN';
  static const String _refreshTokenKey = 'REFRESHTOKEN';

  //Aceder a datos
  static String userName = '';

  static Future<void> loadSession() async {
    final preferences = await SharedPreferences.getInstance();
    userName = preferences.getString(_fullNameKey) ?? '';
  }

  static Future<String> getFullName() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_fullNameKey) ?? 'Usuario';
  }

  //  ACCESS TOKEN
  static Future<void> setAccessToken(String token) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_accessTokenKey, token);
  }

  static Future<String> getAccessToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_accessTokenKey) ?? '';
  }

  //  OBTENER ROL
  static Future<String> getRole() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_roleKey) ?? '';
  }

  // Para saber si el user esta logeado
  static Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token.isNotEmpty;
  }

  // GUARDAR SESIÓN COMPLETA
  // Usamos la Entidad del dominio
  static Future<void> setUserSession(LoginDataEntity userData) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_idKey, userData.id);
    await preferences.setString(_fullNameKey, userData.fullName);
    await preferences.setString(_emailKey, userData.email);
    await preferences.setString(_roleKey, userData.roleName);
    await preferences.setString(_accessTokenKey, userData.sessionToken);
  }

  //  CLEAR
  static Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_idKey);
    await preferences.remove(_fullNameKey);
    await preferences.remove(_emailKey);
    await preferences.remove(_roleKey);
    await preferences.remove(_accessTokenKey);
    await preferences.remove(_refreshTokenKey);
  }

  //  VALIDACIÓN DE SESIÓN
  static Future<bool> isSession() async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getString(_accessTokenKey) ?? '').isNotEmpty;
  }
}
