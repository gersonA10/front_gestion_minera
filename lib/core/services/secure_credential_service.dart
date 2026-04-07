import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureCredentialService {
  static const _storage = FlutterSecureStorage();

  static const _usernameKey = 'biometric_username';
  static const _passwordKey = 'biometric_password';
  static const _enabledKey = 'biometric_enabled';

  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _enabledKey);
    return value == 'true';
  }

  static Future<void> saveCredentials(
      String username, String password) async {
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _passwordKey, value: password);
    await _storage.write(key: _enabledKey, value: 'true');
  }

  static Future<({String username, String password})?> getCredentials() async {
    final username = await _storage.read(key: _usernameKey);
    final password = await _storage.read(key: _passwordKey);
    if (username == null || password == null) return null;
    return (username: username, password: password);
  }

  static Future<void> clearCredentials() async {
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _passwordKey);
    await _storage.delete(key: _enabledKey);
  }
}
