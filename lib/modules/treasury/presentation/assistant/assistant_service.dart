import 'package:front_gestion_minera/core/networking/base_api_exception.dart';
import 'package:front_gestion_minera/core/voice/spanish_number_normalizer.dart';
import 'package:front_gestion_minera/utils/error.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/entity.dart';
import '../../domain/repositories/treasury_repository.dart';
import '../voice/transaction_voice_parser.dart';
import 'assistant_intent_parser.dart';
import 'assistant_period_parser.dart';

/// Acción opcional que la pantalla de chat puede ofrecer junto a la
/// respuesta (deep-link a otra pantalla).
enum AssistantAction {
  ninguna,
  abrirReportes,
  abrirOro,
  abrirDistribuciones,
  abrirAportes,
  abrirPrestamosSocio,
}

class AssistantReply {
  final String text;
  final List<String> suggestions;
  final AssistantAction action;
  final bool isError;

  const AssistantReply({
    required this.text,
    this.suggestions = const [],
    this.action = AssistantAction.ninguna,
    this.isError = false,
  });
}

/// Contrato de un asistente por rol: la pantalla de chat funciona con
/// cualquier implementación (hacienda, socios, ...).
abstract class AssistantEngine {
  String get welcomeText;
  List<String> get welcomeSuggestions;
  Future<AssistantReply> ask(String question);
}

/// Manejo de errores compartido por todos los asistentes.
mixin AssistantErrorHandler {
  Future<AssistantReply> guarded(Future<AssistantReply> Function() body) async {
    try {
      return await body();
    } on BaseApiException catch (e) {
      if (e.key == DioExceptionKey.unauthorised) {
        return const AssistantReply(
          text:
              'Tu sesión expiró. Vuelve a iniciar sesión para seguir '
              'consultando.',
          isError: true,
        );
      }
      return AssistantReply(
        text: '${mapErrorMessage(e.key)} No pude consultar los datos.',
        isError: true,
        suggestions: const ['Reintentar'],
      );
    } catch (_) {
      return const AssistantReply(
        text:
            'Ocurrió un error inesperado al consultar los datos. '
            'Intenta de nuevo en un momento.',
        isError: true,
        suggestions: ['Reintentar'],
      );
    }
  }
}

/// Asistente de consultas de tesorería (rol hacienda) basado en reglas
/// (sin IA): interpreta la pregunta, llama a los endpoints existentes con
/// el token del usuario y redacta la respuesta.
class AssistantService with AssistantErrorHandler implements AssistantEngine {
  final TreasuryRepository repository;

  AssistantService({required this.repository});

  @override
  String get welcomeText =>
      '¡Hola! Soy el asistente de tesorería. Pregúntame por el oro en '
      'bóveda, las ventas, las cajas, los movimientos (de hoy o de '
      'cualquier mes), las solicitudes o los préstamos — escribiendo o '
      'dictando por voz.';

  @override
  List<String> get welcomeSuggestions => defaultSuggestions;

  static const List<String> defaultSuggestions = [
    '¿Cuánto oro hay en bóveda?',
    '¿Cuánto vendimos este mes?',
    '¿Cuánto hay en cajas?',
    'Movimientos de hoy',
    'Solicitudes pendientes',
    'Préstamos activos',
  ];

  // ── Formateadores compartidos por todos los asistentes (es_BO) ─────────
  static final NumberFormat _moneyFormat = NumberFormat.currency(
    locale: 'es_BO',
    symbol: 'Bs ',
    decimalDigits: 2,
  );
  static final NumberFormat _gramsEnteros = NumberFormat.decimalPatternDigits(
    locale: 'es_BO',
    decimalDigits: 0,
  );
  static final NumberFormat _gramsDecimales = NumberFormat.decimalPatternDigits(
    locale: 'es_BO',
    decimalDigits: 2,
  );

  static String formatMoney(double value) => _moneyFormat.format(value);

  static String formatGrams(double value) {
    final f = value == value.roundToDouble() ? _gramsEnteros : _gramsDecimales;
    return '${f.format(value)} g';
  }

  @override
  Future<AssistantReply> ask(String question) {
    return guarded(() async {
      final intent = AssistantIntentParser.parse(question);
      switch (intent) {
        case AssistantIntent.oro:
          return await _oro();
        case AssistantIntent.ventas:
          return await _ventas(question);
        case AssistantIntent.cajas:
          return await _cajas(question);
        case AssistantIntent.movimientosHoy:
          return await _movimientos(question);
        case AssistantIntent.solicitudes:
          return await _solicitudes();
        case AssistantIntent.prestamos:
          return await _prestamos();
        case AssistantIntent.dividendos:
        case AssistantIntent.aportes:
          return const AssistantReply(
            text:
                'Los aportes y distribuciones de los socios se gestionan '
                'desde sus módulos en tesorería. En el chat puedo darte '
                'cajas, movimientos, solicitudes y préstamos.',
            suggestions: defaultSuggestions,
          );
        case AssistantIntent.reportes:
          return const AssistantReply(
            text:
                'Los reportes financieros muestran ingresos, egresos y '
                'conciliaciones por periodo, con exportación a PDF/CSV.',
            action: AssistantAction.abrirReportes,
            suggestions: ['Movimientos de hoy', '¿Cuánto hay en cajas?'],
          );
        case AssistantIntent.ayuda:
        case AssistantIntent.saludo:
          return AssistantReply(
            text:
                '¡Hola! Puedo responderte al instante con datos del sistema. '
                'Prueba con una de estas preguntas, o escríbela con tus '
                'palabras:',
            suggestions: welcomeSuggestions,
          );
        case AssistantIntent.desconocido:
          return const AssistantReply(
            text:
                'No entendí la pregunta. Por ahora puedo responder sobre '
                'oro en bóveda, ventas, cajas, movimientos (de hoy o de un '
                'mes, ej. "egresos de mayo"), solicitudes pendientes, '
                'préstamos y reportes.',
            suggestions: defaultSuggestions,
          );
      }
    });
  }

  Future<AssistantReply> _oro() async {
    final inv = await repository.getGoldInventory();
    if (inv.totalGramsVault <= 0) {
      return const AssistantReply(
        text: 'La bóveda está vacía: no hay oro disponible ahora mismo.',
        suggestions: ['¿Cuánto vendimos este mes?', 'Movimientos de hoy'],
      );
    }
    return AssistantReply(
      text:
          'En bóveda hay ${formatGrams(inv.totalGramsVault)} de oro.\n'
          'Valor estimado: ${formatMoney(inv.estimateValue)} '
          '(precio de referencia ${formatMoney(inv.priceReference)} por gramo).',
      action: AssistantAction.abrirOro,
      suggestions: const [
        '¿Cuánto vendimos este mes?',
        '¿Cuánto hay en cajas?',
      ],
    );
  }

  Future<AssistantReply> _ventas(String question) async {
    final history = await repository.getSalesHistory(page: 1, limit: 1);
    final stats = history.meta;
    if (stats.vendidoDelAnioG <= 0) {
      return const AssistantReply(
        text: 'Aún no hay ventas registradas en el año.',
        suggestions: ['¿Cuánto oro hay en bóveda?'],
      );
    }
    final soloAnio = AssistantIntentParser.asksForYear(question);
    final periodo = AssistantPeriodParser.parse(question);
    // El endpoint de ventas solo expone acumulados del periodo vigente.
    final periodoNoSoportado = periodo != null && !periodo.isCurrent;
    final lineas = <String>[
      if (!soloAnio)
        'Este mes se vendieron ${formatGrams(stats.vendidoEsteMesG)} '
            '(variación: ${stats.variacionMesPct}).',
      'En el año van ${formatGrams(stats.vendidoDelAnioG)} vendidos '
          'en ${stats.totalRegistros} venta(s).',
      if (periodoNoSoportado)
        'Por ahora solo tengo el acumulado del mes en curso y del año; '
            'el detalle por periodo está en el historial de ventas.',
    ];
    return AssistantReply(
      text: lineas.join('\n'),
      action: periodoNoSoportado
          ? AssistantAction.abrirOro
          : AssistantAction.ninguna,
      suggestions: const ['¿Cuánto oro hay en bóveda?', 'Movimientos de hoy'],
    );
  }

  Future<AssistantReply> _cajas(String question) async {
    final resultados = await Future.wait([
      repository.getBondBalence(),
      repository.getCashRegisters(),
    ]);
    final balance = resultados[0] as BondBalanceResponseEntity;
    final cajas = resultados[1] as List<CashRegisterEntity>;

    // ¿Preguntó por una caja específica? ("cuánto hay en caja chica")
    // Usa el mismo matcher que el dictado de transacciones.
    final matches = TransactionVoiceParser.matchCajas(
      SpanishNumberNormalizer.clean(question),
      cajas,
    );
    if (matches.isNotEmpty) {
      final c = cajas.firstWhere((caja) => caja.id == matches.first.$1);
      return AssistantReply(
        text:
            'En ${c.nombre} hay ${formatMoney(c.saldoDisponible)} '
            'disponibles.',
        suggestions: const ['¿Cuánto hay en cajas?', 'Movimientos de hoy'],
      );
    }

    final detalle = cajas
        .map((c) => '• ${c.nombre}: ${formatMoney(c.saldoDisponible)}')
        .join('\n');
    return AssistantReply(
      text:
          'Total en cajas: ${formatMoney(balance.cajaMayor + balance.cajaChica)}\n'
          '$detalle\n'
          'Disponible real: ${formatMoney(balance.saldoDisponibleReal)} '
          '(por desembolsar: ${formatMoney(balance.aDesembolsar)}).',
      suggestions: const ['Movimientos de hoy', 'Solicitudes pendientes'],
    );
  }

  Future<AssistantReply> _movimientos(String question) async {
    final periodo = AssistantPeriodParser.parse(question);

    // Sin periodo (o el día vigente): el resumen del historial ya trae hoy.
    if (periodo == null || (periodo.period == 'day' && periodo.isCurrent)) {
      final PaymentHistoryResponseEntity history = await repository
          .getPaymentHistory(page: 1, limit: 3);
      final s = history.summary;
      if (s.totalTransaccionesHoy == 0) {
        return const AssistantReply(
          text: 'Hoy todavía no hay movimientos registrados.',
          suggestions: ['Egresos de este mes', '¿Cuánto hay en cajas?'],
        );
      }
      return AssistantReply(
        text:
            'Movimientos de hoy (${s.totalTransaccionesHoy} transacciones):\n'
            '• Ingresos: ${formatMoney(s.totalIngresosHoy)}\n'
            '• Egresos: ${formatMoney(s.totalMontoHoy)}',
        action: AssistantAction.abrirReportes,
        suggestions: const ['Egresos de este mes', '¿Cuánto hay en cajas?'],
      );
    }

    // Con periodo ("de mayo", "este mes", "ayer"): usa el reporte financiero.
    final report = await repository.getFinancialReport(
      period: periodo.period,
      exactDate: periodo.exactDate,
    );
    final r = report.resumenGeneral;
    if (r.ingresosTotales == 0 && r.egresosTotales == 0) {
      return AssistantReply(
        text: 'No hay movimientos registrados en ${periodo.label}.',
        suggestions: const ['Movimientos de hoy', '¿Cuánto hay en cajas?'],
      );
    }

    final lineas = <String>[
      'Resumen de ${periodo.label}:',
      '• Ingresos: ${formatMoney(r.ingresosTotales)}',
      '• Egresos: ${formatMoney(r.egresosTotales)}',
      '• Balance: ${formatMoney(r.balanceNeto)} (${r.estadoSalud})',
    ];

    // Si preguntan en qué se gasta, agrega el desglose por área.
    final q = SpanishNumberNormalizer.clean(question);
    final pideDesglose =
        q.contains('gasta') ||
        q.contains('gasto') ||
        q.contains('egreso') ||
        q.contains('en que se');
    final gastos = report.gastosPorResponsable;
    if (pideDesglose && gastos.isNotEmpty) {
      lineas.add('Egresos por área:');
      for (final g in gastos.take(4)) {
        lineas.add(
          '• ${g.area}: ${formatMoney(g.monto)} '
          '(${g.porcentajeDelTotal.toStringAsFixed(0)}%)',
        );
      }
    }

    return AssistantReply(
      text: lineas.join('\n'),
      action: AssistantAction.abrirReportes,
      suggestions: const ['Movimientos de hoy', '¿Cuánto hay en cajas?'],
    );
  }

  Future<AssistantReply> _solicitudes() async {
    final resp = await repository.getPendingApplications();
    final items = resp.data;
    if (items.isEmpty) {
      return const AssistantReply(
        text: 'No hay solicitudes pendientes de aprobación. ✅',
        suggestions: ['Movimientos de hoy', 'Préstamos activos'],
      );
    }
    final total = items.fold<int>(0, (sum, i) => sum + i.monto);
    final top = items
        .take(3)
        .map(
          (i) =>
              '• ${i.solicitante}: ${formatMoney(i.monto.toDouble())} — ${i.motivo}',
        )
        .join('\n');
    final extra = items.length > 3 ? '\n…y ${items.length - 3} más.' : '';
    return AssistantReply(
      text:
          'Hay ${items.length} solicitud(es) pendiente(s) por '
          '${formatMoney(total.toDouble())}:\n$top$extra',
      suggestions: const ['¿Cuánto hay en cajas?', 'Movimientos de hoy'],
    );
  }

  Future<AssistantReply> _prestamos() async {
    final resp = await repository.getInternalLoans(page: 1, limit: 50);
    if (resp.items.isEmpty) {
      return const AssistantReply(
        text: 'No hay préstamos registrados.',
        suggestions: ['¿Cuánto hay en cajas?', 'Solicitudes pendientes'],
      );
    }
    final activos = resp.items.where((l) => l.pendiente > 0).toList();
    final pendienteTotal = activos.fold<double>(
      0,
      (sum, l) => sum + l.pendiente,
    );
    if (activos.isEmpty) {
      return AssistantReply(
        text:
            'Hay ${resp.totalRecords} préstamo(s) registrados y ninguno '
            'tiene saldo pendiente. ✅',
        suggestions: const ['¿Cuánto hay en cajas?'],
      );
    }
    final top = activos
        .take(3)
        .map(
          (l) =>
              '• ${l.lenderName} (${l.loanCode}): pendiente ${formatMoney(l.pendiente)} — ${l.progresoPagoPct}% pagado',
        )
        .join('\n');
    final extra = activos.length > 3 ? '\n…y ${activos.length - 3} más.' : '';
    return AssistantReply(
      text:
          'Hay ${activos.length} préstamo(s) con saldo pendiente por '
          '${formatMoney(pendienteTotal)}:\n$top$extra',
      suggestions: const ['¿Cuánto hay en cajas?', 'Movimientos de hoy'],
    );
  }
}
