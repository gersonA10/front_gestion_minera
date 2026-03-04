import 'package:front_gestion_minera/modules/auth/data/models/auth_model.dart';
import 'package:shared_preferences/shared_preferences.dart';



class UserSession {
  // Aquí irás agregando más llaves según crezca el proyecto (ej. ROL, SUCURSAL)
  static const String _idKey = 'ID';
  static const String _nameKey = 'NAME';
  static const String _emailKey = 'EMAIL';
  static const String _accessTokenKey = 'TOKEN';
  static const String _refreshTokenKey = 'REFRESHTOKEN';

  // --- ACCESS TOKEN ---
  static Future<void> setAccessToken(String token) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_accessTokenKey, token);
  }

  static Future<String> getAccessToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_accessTokenKey) ?? '';
  }

  // --- REFRESH TOKEN ---
  static Future<void> setRefreshToken(String refreshtoken) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_refreshTokenKey, refreshtoken);
  }

  static Future<String> getRefreshToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_refreshTokenKey) ?? '';
  }

  // --- USER DATA BÁSICA (Opcional por ahora) ---
  static Future<void> setUserData({
    required LoginDataModel userData,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_idKey, userData.id);
    await preferences.setString(_nameKey, userData.email);
    await preferences.setString(_emailKey, userData.roleName);
    await preferences.setString( _accessTokenKey, userData.sessionToken);
  }

  // --- CLEAR (Ideal para el Logout) ---
  static Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_idKey);
    await preferences.remove(_nameKey);
    await preferences.remove(_emailKey);
    await preferences.remove(_accessTokenKey);
    await preferences.remove(_refreshTokenKey);
  }

  // --- VALIDACIÓN DE SESIÓN ---
  static Future<bool> isSession() async {
    final preferences = await SharedPreferences.getInstance();
    // Validamos por el token en lugar del ID, es más seguro para saber si hay sesión activa
    return (preferences.getString(_accessTokenKey) ?? '').isNotEmpty;
  }
}