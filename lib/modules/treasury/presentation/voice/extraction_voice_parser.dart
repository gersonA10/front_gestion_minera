import 'package:front_gestion_minera/core/voice/spanish_number_normalizer.dart';

/// Resultado de interpretar un dictado de registro de extracción.
class ExtractionVoiceResult {
  final String transcript;
  final double? weightGrams;
  final double purityPercent;
  final bool purityWasSaid;
  final DateTime extractionDate;
  final bool dateWasSaid;

  const ExtractionVoiceResult({
    required this.transcript,
    required this.weightGrams,
    required this.purityPercent,
    required this.purityWasSaid,
    required this.extractionDate,
    required this.dateWasSaid,
  });

  bool get hasWeight => weightGrams != null && weightGrams! > 0;

  /// Regla del backend: la pureza debe estar entre 90% y 99%.
  bool get purityIsValid => purityPercent >= 90 && purityPercent <= 99;

  bool get isValid => hasWeight && purityIsValid;
}

/// Interpreta comandos como:
///   "registrar extracción de oro 15 gramos"
///   "extracción de quince punto cinco gramos con pureza 94"
///   "registrar 1 kilo de oro de ayer pureza noventa y dos"
class ExtractionVoiceParser {
  static const double _defaultPurity = 96;

  static ExtractionVoiceResult parse(String transcript, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final normalized = SpanishNumberNormalizer.normalize(
      transcript,
    ).replaceAll(',', '.');

    final purity = _parsePurity(normalized);
    final weight = _parseWeight(normalized, purityText: purity?.$2);
    final date = _parseDate(normalized, today);

    return ExtractionVoiceResult(
      transcript: transcript,
      weightGrams: weight,
      purityPercent: purity?.$1 ?? _defaultPurity,
      purityWasSaid: purity != null,
      extractionDate: date ?? DateTime(today.year, today.month, today.day),
      dateWasSaid: date != null,
    );
  }

  /// Devuelve (valor, texto completo del match) o null si no se dictó pureza.
  static (double, String)? _parsePurity(String text) {
    final withKeyword = RegExp(
      r'(?:pureza|ley)\s+(?:de\s+|del\s+|al\s+)?(\d+(?:\.\d+)?)',
    ).firstMatch(text);
    if (withKeyword != null) {
      return (double.parse(withKeyword.group(1)!), withKeyword.group(0)!);
    }
    final withPercent = RegExp(
      r'(\d+(?:\.\d+)?)\s*(?:%|por\s?ciento)',
    ).firstMatch(text);
    if (withPercent != null) {
      return (double.parse(withPercent.group(1)!), withPercent.group(0)!);
    }
    return null;
  }

  static double? _parseWeight(String text, {String? purityText}) {
    // Con unidad explícita: gramos o kilos.
    final withUnit = RegExp(
      r'(\d+(?:\.\d+)?)\s*(kilos?|kilogramos?|kg|gramos?|grs?|gr|g)\b',
    ).firstMatch(text);
    if (withUnit != null) {
      final value = double.parse(withUnit.group(1)!);
      final unit = withUnit.group(2)!;
      final isKilo = unit.startsWith('k');
      return isKilo ? value * 1000 : value;
    }

    // Sin unidad: usar el primer número que no sea parte de la pureza.
    var remaining = text;
    if (purityText != null) {
      remaining = remaining.replaceFirst(purityText, ' ');
    }
    final loneNumber = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(remaining);
    if (loneNumber != null) {
      return double.parse(loneNumber.group(1)!);
    }
    return null;
  }

  /// El formulario solo permite registrar de hoy hasta 3 días atrás.
  static DateTime? _parseDate(String text, DateTime today) {
    final day = DateTime(today.year, today.month, today.day);
    if (RegExp(r'\b(anteayer|antier|antes de ayer)\b').hasMatch(text)) {
      return day.subtract(const Duration(days: 2));
    }
    if (RegExp(r'\bayer\b').hasMatch(text)) {
      return day.subtract(const Duration(days: 1));
    }
    final daysAgo = RegExp(r'hace\s+(\d+)\s+dias?').firstMatch(text);
    if (daysAgo != null) {
      final n = int.parse(daysAgo.group(1)!).clamp(0, 3);
      return day.subtract(Duration(days: n));
    }
    if (RegExp(r'\bhoy\b').hasMatch(text)) {
      return day;
    }
    return null;
  }
}
