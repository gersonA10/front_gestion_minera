import 'package:flutter_test/flutter_test.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/assistant/assistant_intent_parser.dart';

void main() {
  group('AssistantIntentParser', () {
    test('preguntas de oro / bóveda', () {
      expect(
        AssistantIntentParser.parse('¿Cuánto oro hay en bóveda?'),
        AssistantIntent.oro,
      );
      expect(
        AssistantIntentParser.parse('cuantos gramos tenemos'),
        AssistantIntent.oro,
      );
    });

    test('ventas gana sobre oro cuando pregunta por vendido', () {
      expect(
        AssistantIntentParser.parse('¿cuántos gramos vendimos este mes?'),
        AssistantIntent.ventas,
      );
      expect(
        AssistantIntentParser.parse('cuánto vendimos en el año'),
        AssistantIntent.ventas,
      );
      expect(
        AssistantIntentParser.asksForYear('cuánto vendimos en el año'),
        true,
      );
      expect(
        AssistantIntentParser.asksForYear('cuánto vendimos este mes'),
        false,
      );
    });

    test('cajas y saldos', () {
      expect(
        AssistantIntentParser.parse('¿cuánto hay en cajas?'),
        AssistantIntent.cajas,
      );
      expect(
        AssistantIntentParser.parse('saldo de caja chica'),
        AssistantIntent.cajas,
      );
    });

    test('"en qué se gasta el dinero" es movimientos, no cajas', () {
      expect(
        AssistantIntentParser.parse('¿en qué se gasta el dinero?'),
        AssistantIntent.movimientosHoy,
      );
      expect(
        AssistantIntentParser.parse('egresos de hoy'),
        AssistantIntent.movimientosHoy,
      );
    });

    test('solicitudes, préstamos y reportes', () {
      expect(
        AssistantIntentParser.parse('¿hay solicitudes pendientes?'),
        AssistantIntent.solicitudes,
      );
      expect(
        AssistantIntentParser.parse('cuánto hay de préstamos'),
        AssistantIntent.prestamos,
      );
      expect(
        AssistantIntentParser.parse('muéstrame el reporte financiero'),
        AssistantIntent.reportes,
      );
    });

    test('intenciones de socios: dividendos y aportes', () {
      expect(
        AssistantIntentParser.parse('¿cuánto me toca de dividendos?'),
        AssistantIntent.dividendos,
      );
      expect(
        AssistantIntentParser.parse('¿cuánto he aportado?'),
        AssistantIntent.aportes,
      );
      expect(
        AssistantIntentParser.parse('mis contribuciones'),
        AssistantIntent.aportes,
      );
    });

    // ── Regresiones de la revisión pre-producción ─────────────────────────
    test('"pendiente" no roba las preguntas de préstamos', () {
      expect(
        AssistantIntentParser.parse('¿cuánto tengo pendiente de mi préstamo?'),
        AssistantIntent.prestamos,
      );
      expect(
        AssistantIntentParser.parse('solicitudes pendientes'),
        AssistantIntent.solicitudes,
      );
    });

    test('"hoy" no roba las preguntas de cajas', () {
      expect(
        AssistantIntentParser.parse('¿cuánto hay en caja chica hoy?'),
        AssistantIntent.cajas,
      );
      expect(
        AssistantIntentParser.parse('movimientos de hoy'),
        AssistantIntent.movimientosHoy,
      );
    });

    test('saludo, ayuda y desconocido', () {
      expect(AssistantIntentParser.parse('hola'), AssistantIntent.saludo);
      expect(
        AssistantIntentParser.parse('¿qué puedes hacer?'),
        AssistantIntent.ayuda,
      );
      expect(
        AssistantIntentParser.parse('me gusta el fútbol'),
        AssistantIntent.desconocido,
      );
    });
  });
}
