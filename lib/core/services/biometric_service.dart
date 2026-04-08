import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Returns true if the device supports biometrics AND has enrolled biometrics.
  static Future<bool> isAvailable() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      if (!isSupported) return false;
      final canCheck = await _auth.canCheckBiometrics;
      return canCheck;
    } catch (_) {
      return false;
    }
  }

  /// Returns the available biometric types on this device.
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Launches the biometric prompt with Spanish messages.
  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Usa tu huella para acceder al sistema',
        biometricOnly: false,
        persistAcrossBackgrounding: false,
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Verificar identidad',
            signInHint: 'Toca el sensor de huella dactilar',
            cancelButton: 'Cancelar',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancelar',
            localizedFallbackTitle: 'Usar contraseña',
          ),
        ],
      );
    } catch (_) {
      return false;
    }
  }
}
