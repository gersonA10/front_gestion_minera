import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Voz del tutorial (coach marks): lee en español el texto de cada paso
/// mientras el usuario recorre el showcase. Singleton ligero y perezoso.
///
/// Se engancha al callback `onStart(index, key)` de `ShowcaseView.register`:
/// cada vez que aparece un coach mark, se llama a [speak] con su texto.
///
/// **La voz es la misma en TODOS los tutoriales** (admin, socios, hacienda,
/// personal, …) porque:
///  - es un único singleton compartido,
///  - la selección de voz es **determinista** (mismo orden → mismo resultado),
///  - la voz elegida se **cachea** en SharedPreferences y se reutiliza tal cual
///    en cada pantalla y en cada sesión (hasta subir [_kVoiceCacheKey]).
///
/// Para que NO suene robótica: en Android usa el motor de Google, prefiere
/// voces naturales (enhanced/network) y **masculinas en español latino**, y
/// castiga las "compact"/"eloquence".
class TutorialTts {
  TutorialTts._();
  static final TutorialTts instance = TutorialTts._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  /// Cache de la voz elegida (`name|locale`). Subir el sufijo de versión
  /// fuerza re-seleccionar la voz ignorando la cacheada.
  static const String _kVoiceCacheKey = 'TUTORIAL_TTS_VOICE_V2';

  /// Pistas de voces **masculinas** en español (nombre o id). Es la voz que el
  /// usuario prefiere (la del módulo admin).
  static const List<String> _maleHints = [
    'juan', 'diego', 'jorge', 'carlos', 'pablo', 'miguel', 'enrique', 'arnau',
  ];

  /// Pistas de voces **femeninas** para deprivilegiarlas (queremos masculina).
  static const List<String> _femaleHints = [
    'paulina', 'monica', 'mónica', 'marisol', 'angelica', 'angélica',
    'esperanza', 'penelope', 'penélope', 'lucia', 'lucía', 'sofia', 'sofía',
  ];

  Future<void> _ensureInit() async {
    if (_initialized) return;
    _initialized = true;
    try {
      // Android: motor de Google = voces mucho más naturales que el de fábrica.
      if (Platform.isAndroid) {
        try {
          final engines = await _tts.getEngines;
          if (engines is List && engines.contains('com.google.android.tts')) {
            await _tts.setEngine('com.google.android.tts');
          }
        } catch (_) {}
      }

      // iOS: usar la instancia compartida de audio.
      if (Platform.isIOS) {
        try {
          await _tts.setSharedInstance(true);
        } catch (_) {}
      }

      await _tts.awaitSpeakCompletion(true);
      // Ritmo un poco más lento y tono NEUTRO (un pitch alto suena metálico).
      await _tts.setSpeechRate(Platform.isIOS ? 0.45 : 0.48);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);

      await _applyConsistentVoice();
    } catch (_) {
      // El TTS es un extra; nunca debe romper el tutorial.
    }
  }

  /// Devuelve las voces en español del dispositivo, con reintentos por si el
  /// motor aún no está listo justo tras arrancar (evita caer al default robótico).
  Future<List<Map<String, String>>> _spanishVoices() async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final raw = await _tts.getVoices;
        if (raw is List && raw.isNotEmpty) {
          final list = raw
              .whereType<Map>()
              .map((v) => v.map((k, val) => MapEntry('$k', '$val')))
              .where((v) => (v['locale'] ?? '').toLowerCase().startsWith('es'))
              .toList();
          if (list.isNotEmpty) return list;
        }
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 250));
    }
    return [];
  }

  /// Aplica SIEMPRE la misma voz: si hay una cacheada y sigue disponible la
  /// reutiliza; si no, elige la mejor de forma determinista y la cachea.
  Future<void> _applyConsistentVoice() async {
    final spanish = await _spanishVoices();
    if (spanish.isEmpty) {
      // Sin lista de voces: al menos fijamos un español latino.
      try {
        await _tts.setLanguage('es-US');
      } catch (_) {}
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // 1) Voz cacheada → reutilizarla si sigue instalada (misma voz siempre).
    final cached = prefs.getString(_kVoiceCacheKey);
    if (cached != null) {
      final parts = cached.split('|');
      if (parts.length == 2 &&
          spanish.any((v) => v['name'] == parts[0] && v['locale'] == parts[1])) {
        await _tts.setLanguage(parts[1]);
        await _tts.setVoice({'name': parts[0], 'locale': parts[1]});
        return;
      }
    }

    // 2) Selección determinista: natural > masculina > latina; desempate estable
    //    por nombre para que el resultado sea idéntico en cada arranque.
    spanish.sort((a, b) {
      final byScore = _score(b).compareTo(_score(a));
      if (byScore != 0) return byScore;
      return (a['name'] ?? '').compareTo(b['name'] ?? '');
    });

    final best = spanish.first;
    final name = best['name'];
    final locale = best['locale'];
    if (locale != null) await _tts.setLanguage(locale);
    if (name != null && locale != null) {
      await _tts.setVoice({'name': name, 'locale': locale});
      await prefs.setString(_kVoiceCacheKey, '$name|$locale');
    }
  }

  int _score(Map<String, String> v) {
    final name = (v['name'] ?? '').toLowerCase();
    final id = (v['identifier'] ?? '').toLowerCase();
    final locale = (v['locale'] ?? '').toLowerCase();
    final gender = (v['gender'] ?? '').toLowerCase();
    final quality = (v['quality'] ?? '').toLowerCase();
    final hay = '$name $id $quality';
    var s = 0;

    // Calidad numérica (Android: 100 baja … 500 muy alta).
    final q = int.tryParse(v['quality'] ?? '');
    if (q != null) s += q ~/ 50;

    // Naturalidad (lo más importante: domina sobre el género).
    if (hay.contains('enhanced') ||
        hay.contains('premium') ||
        hay.contains('neural') ||
        hay.contains('siri')) {
      s += 12;
    }
    if (hay.contains('network') || hay.contains('-eea-')) s += 10;
    // Robóticas: castigo fuerte.
    if (hay.contains('compact') ||
        hay.contains('eloquence') ||
        hay.contains('-local') ||
        hay.contains('low')) {
      s -= 12;
    }

    // Preferir masculina (la voz de admin que le gusta al usuario).
    if (gender == 'male') s += 6;
    if (_maleHints.any(name.contains)) s += 5;
    if (gender == 'female') s -= 3;
    if (_femaleHints.any(name.contains)) s -= 4;

    // Español latino (más cálido/familiar que el castellano).
    if (locale.startsWith('es-us') ||
        locale.startsWith('es-mx') ||
        locale.startsWith('es-419') ||
        locale.startsWith('es-ar') ||
        locale.startsWith('es-co')) {
      s += 3;
    }
    if (locale == 'es-es') s += 1;
    return s;
  }

  /// Detiene lo que se esté diciendo y lee [text]. Ignora texto vacío.
  Future<void> speak(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;
    try {
      await _ensureInit();
      await _tts.stop();
      await _tts.speak(clean);
    } catch (_) {
      // TTS es un extra; nunca debe romper el tutorial.
    }
  }

  /// Corta la voz (al saltar/terminar el tutorial o salir de la pantalla).
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  /// Borra la voz cacheada para forzar una nueva selección (debug/QA).
  Future<void> resetVoice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kVoiceCacheKey);
    } catch (_) {}
  }
}
