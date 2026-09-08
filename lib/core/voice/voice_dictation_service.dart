import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Envuelve speech_to_text con la configuración estándar de la app:
/// locale en español, resultados parciales y mensajes de error en español.
class VoiceDictationService {
  final SpeechToText _speech = SpeechToText();

  bool _initialized = false;
  String? _localeId;
  void Function(String message)? _onError;

  // Al llamar stop() el reconocedor nativo emite un último resultado
  // "final" tardío; se suprime aquí para que ningún consumidor procese
  // el dictado dos veces (bug real: doble pop cerraba la pantalla de abajo).
  bool _suppressResults = false;

  bool get isListening => _speech.isListening;

  /// Inicializa el reconocedor y resuelve el locale en español disponible.
  /// Devuelve false si el dispositivo no soporta reconocimiento o el usuario
  /// negó el permiso de micrófono.
  Future<bool> init({void Function(String message)? onError}) async {
    _onError = onError;
    if (_initialized) return true;

    _initialized = await _speech.initialize(
      onError: (SpeechRecognitionError e) {
        _onError?.call(_mapError(e.errorMsg));
      },
    );

    if (_initialized) {
      final locales = await _speech.locales();
      final spanish = locales.where(
        (l) => l.localeId.toLowerCase().startsWith('es'),
      );
      if (spanish.isNotEmpty) {
        // Prioriza es_BO si existe; si no, el primer español disponible.
        _localeId = spanish
            .firstWhere(
              (l) => l.localeId.toLowerCase().contains('bo'),
              orElse: () => spanish.first,
            )
            .localeId;
      }
    }
    return _initialized;
  }

  /// Empieza a escuchar. [onResult] recibe el texto acumulado y si es final.
  Future<void> listen({
    required void Function(String text, bool isFinal) onResult,
  }) async {
    if (!_initialized) return;
    _suppressResults = false;
    await _speech.listen(
      onResult: (result) {
        if (_suppressResults) return;
        onResult(result.recognizedWords, result.finalResult);
      },
      listenOptions: SpeechListenOptions(
        localeId: _localeId,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
        partialResults: true,
        listenMode: ListenMode.dictation,
      ),
    );
  }

  Future<void> stop() {
    _suppressResults = true;
    return _speech.stop();
  }

  Future<void> cancel() {
    _suppressResults = true;
    return _speech.cancel();
  }

  String _mapError(String code) {
    switch (code) {
      case 'error_no_match':
      case 'error_speech_timeout':
        return 'No se entendió el dictado. Intenta de nuevo.';
      case 'error_audio':
      case 'error_audio_error':
        return 'Problema con el micrófono. Verifica el permiso e intenta de nuevo.';
      case 'error_network':
      case 'error_network_timeout':
        return 'Sin conexión para el reconocimiento de voz.';
      case 'error_permission':
      case 'error_insufficient_permissions':
        return 'Permiso de micrófono denegado. Actívalo en los ajustes del teléfono.';
      case 'error_busy':
        return 'El reconocedor está ocupado. Intenta de nuevo.';
      default:
        return 'Error de reconocimiento de voz. Intenta de nuevo.';
    }
  }
}
