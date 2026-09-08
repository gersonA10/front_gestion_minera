import 'package:front_gestion_minera/core/voice/spanish_number_normalizer.dart';

/// Qué quiere saber el usuario. El asistente NO usa IA: cada intención
/// mapea a endpoints existentes del backend.
enum AssistantIntent {
  oro,
  ventas,
  cajas,
  movimientosHoy,
  solicitudes,
  prestamos,
  dividendos,
  aportes,
  reportes,
  ayuda,
  saludo,
  desconocido,
}

class AssistantIntentParser {
  /// Detecta la intención por palabras clave sobre el texto normalizado
  /// (sin acentos, minúsculas). El orden de los chequeos importa: los más
  /// específicos van primero.
  static AssistantIntent parse(String question) {
    // Sin acentos, minúsculas y sin puntuación (¿? ¡! , . etc.).
    final t =
        ' ${SpanishNumberNormalizer.clean(question).replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')} ';
    bool has(List<String> keywords) => keywords.any(t.contains);

    // Ventas antes que oro: "cuantos gramos vendimos" es ventas.
    if (has([' vendimos', ' vendido', ' venta', ' ventas'])) {
      return AssistantIntent.ventas;
    }
    if (has([' oro', ' boveda', ' inventario', ' lote', ' gramos'])) {
      return AssistantIntent.oro;
    }
    // Gastos/ingresos/movimientos antes que cajas: "en que se gasta el
    // dinero" pregunta por egresos, no por saldos.
    // Nota: ' hoy' NO es keyword aquí — "¿cuánto hay en caja chica hoy?"
    // debe resolver por cajas, no por movimientos.
    if (has([
      ' gasta',
      ' gasto',
      ' gastos',
      ' egreso',
      ' ingreso',
      ' movimiento',
      ' transaccion',
    ])) {
      return AssistantIntent.movimientosHoy;
    }
    if (has([
      ' caja',
      ' saldo',
      ' plata',
      ' dinero',
      ' efectivo',
      ' disponible',
      ' balance',
    ])) {
      return AssistantIntent.cajas;
    }
    // Nota: 'pendiente' NO es keyword — es vocabulario de préstamos,
    // aportes y dividendos ("cuánto tengo pendiente de mi préstamo").
    if (has([' solicitud', ' aprobar', ' reposicion'])) {
      return AssistantIntent.solicitudes;
    }
    if (has([
      ' dividendo',
      ' me toca',
      ' reparto',
      ' utilidades',
      ' distribucion',
    ])) {
      return AssistantIntent.dividendos;
    }
    if (has([' aporte', ' aportado', ' contribucion', ' contribui'])) {
      return AssistantIntent.aportes;
    }
    if (has([' prestamo', ' deuda', ' credito', ' cuota'])) {
      return AssistantIntent.prestamos;
    }
    if (has([' reporte', ' informe', ' estado financiero', ' pdf', ' csv'])) {
      return AssistantIntent.reportes;
    }
    if (has([
      ' ayuda',
      ' que puedes',
      ' que sabes',
      ' opciones',
      ' como funciona',
    ])) {
      return AssistantIntent.ayuda;
    }
    if (has([
      ' hola',
      ' buenos dias',
      ' buenas tardes',
      ' buenas noches',
      ' buenas ',
    ])) {
      return AssistantIntent.saludo;
    }
    return AssistantIntent.desconocido;
  }

  /// ¿La pregunta de ventas se refiere al año? (default: mes + año)
  static bool asksForYear(String question) {
    final t = SpanishNumberNormalizer.clean(question);
    return t.contains('ano') || t.contains('anual') || t.contains('gestion');
  }
}
