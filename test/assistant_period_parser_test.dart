import 'package:flutter_test/flutter_test.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/assistant/assistant_period_parser.dart';

void main() {
  final hoy = DateTime(2026, 7, 15);

  group('AssistantPeriodParser', () {
    test('hoy y ayer', () {
      final h = AssistantPeriodParser.parse('egresos de hoy', now: hoy)!;
      expect(h.period, 'day');
      expect(h.exactDate, '2026-07-15');

      final a = AssistantPeriodParser.parse('¿qué se gastó ayer?', now: hoy)!;
      expect(a.period, 'day');
      expect(a.exactDate, '2026-07-14');
    });

    test('mes por nombre asume el año correcto', () {
      final mayo = AssistantPeriodParser.parse('egresos de mayo', now: hoy)!;
      expect(mayo.period, 'month');
      expect(mayo.exactDate, '2026-05-01');

      // Noviembre aún no llega en 2026 → se asume 2025.
      final nov = AssistantPeriodParser.parse('gastos de noviembre', now: hoy)!;
      expect(nov.exactDate, '2025-11-01');
    });

    test('mes con año explícito', () {
      final p =
          AssistantPeriodParser.parse('egresos de mayo de 2025', now: hoy)!;
      expect(p.period, 'month');
      expect(p.exactDate, '2025-05-01');
      expect(p.label, 'mayo 2025');
    });

    test('día puntual "el 12 de mayo"', () {
      final p = AssistantPeriodParser.parse(
        'movimientos del 12 de mayo',
        now: hoy,
      )!;
      expect(p.period, 'day');
      expect(p.exactDate, '2026-05-12');
    });

    test('este mes, mes pasado, este año, año pasado', () {
      expect(
        AssistantPeriodParser.parse('ingresos de este mes', now: hoy)!.period,
        'month',
      );
      final pasado =
          AssistantPeriodParser.parse('egresos del mes pasado', now: hoy)!;
      expect(pasado.exactDate, '2026-06-01');

      expect(
        AssistantPeriodParser.parse('gastos de este año', now: hoy)!.period,
        'year',
      );
      final anioPasado =
          AssistantPeriodParser.parse('egresos del año pasado', now: hoy)!;
      expect(anioPasado.exactDate, '2025-01-01');
    });

    test('sin periodo devuelve null', () {
      expect(AssistantPeriodParser.parse('¿cuánto hay en cajas?'), isNull);
    });
  });
}
