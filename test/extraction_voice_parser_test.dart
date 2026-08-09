import 'package:flutter_test/flutter_test.dart';
import 'package:front_gestion_minera/core/voice/spanish_number_normalizer.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/voice/extraction_voice_parser.dart';

void main() {
  group('SpanishNumberNormalizer', () {
    test('convierte números simples en palabras a dígitos', () {
      expect(
        SpanishNumberNormalizer.normalize('quince gramos'),
        '15 gramos',
      );
      expect(
        SpanishNumberNormalizer.normalize('noventa y seis por ciento'),
        '96 por ciento',
      );
    });

    test('convierte decimales con punto y coma', () {
      expect(
        SpanishNumberNormalizer.normalize('quince punto cinco gramos'),
        '15.5 gramos',
      );
      expect(
        SpanishNumberNormalizer.normalize('doce coma veinticinco'),
        '12.25',
      );
    });

    test('convierte miles y centenas', () {
      expect(
        SpanishNumberNormalizer.normalize('mil doscientos gramos'),
        '1200 gramos',
      );
      expect(
        SpanishNumberNormalizer.normalize('ciento veinte'),
        '120',
      );
      // Regresión: miles después de la cifra ("cinco mil").
      expect(
        SpanishNumberNormalizer.normalize('cinco mil bolivianos'),
        '5000 bolivianos',
      );
      expect(
        SpanishNumberNormalizer.normalize('dos mil quinientos'),
        '2500',
      );
      expect(
        SpanishNumberNormalizer.normalize('treinta mil'),
        '30000',
      );
      // Y las unidades sueltas siguen intactas.
      expect(
        SpanishNumberNormalizer.normalize('quince punto cinco'),
        '15.5',
      );
    });

    test('deja intacto el texto sin números', () {
      expect(
        SpanishNumberNormalizer.normalize('registrar extraccion de oro'),
        'registrar extraccion de oro',
      );
    });
  });

  group('ExtractionVoiceParser', () {
    final hoy = DateTime(2026, 7, 14);

    test('comando básico con dígitos', () {
      final r = ExtractionVoiceParser.parse(
        'registrar extracción de oro 15 gramos',
        now: hoy,
      );
      expect(r.weightGrams, 15);
      expect(r.purityPercent, 96); // por defecto
      expect(r.purityWasSaid, false);
      expect(r.extractionDate, DateTime(2026, 7, 14));
      expect(r.isValid, true);
    });

    test('peso en palabras con decimales y pureza dictada', () {
      final r = ExtractionVoiceParser.parse(
        'extracción de quince punto cinco gramos con pureza noventa y cuatro',
        now: hoy,
      );
      expect(r.weightGrams, 15.5);
      expect(r.purityPercent, 94);
      expect(r.purityWasSaid, true);
      expect(r.isValid, true);
    });

    test('kilos se convierten a gramos y entiende "ayer"', () {
      final r = ExtractionVoiceParser.parse(
        'registrar 1 kilo de oro de ayer',
        now: hoy,
      );
      expect(r.weightGrams, 1000);
      expect(r.extractionDate, DateTime(2026, 7, 13));
      expect(r.dateWasSaid, true);
    });

    test('pureza como porcentaje', () {
      final r = ExtractionVoiceParser.parse(
        '20 gramos al 92 por ciento',
        now: hoy,
      );
      expect(r.weightGrams, 20);
      expect(r.purityPercent, 92);
    });

    test('pureza fuera del rango 90-99 invalida el registro', () {
      final r = ExtractionVoiceParser.parse(
        '10 gramos pureza 85',
        now: hoy,
      );
      expect(r.purityIsValid, false);
      expect(r.isValid, false);
    });

    test('sin peso el resultado no es válido', () {
      final r = ExtractionVoiceParser.parse(
        'registrar extracción de oro',
        now: hoy,
      );
      expect(r.hasWeight, false);
      expect(r.isValid, false);
    });

    test('número sin unidad se toma como gramos', () {
      final r = ExtractionVoiceParser.parse(
        'registrar extracción de oro de 18 con pureza 95',
        now: hoy,
      );
      expect(r.weightGrams, 18);
      expect(r.purityPercent, 95);
    });

    test('entiende anteayer dentro del rango permitido', () {
      final r = ExtractionVoiceParser.parse(
        'registrar 30 gramos de anteayer',
        now: hoy,
      );
      expect(r.extractionDate, DateTime(2026, 7, 12));
    });
  });
}
