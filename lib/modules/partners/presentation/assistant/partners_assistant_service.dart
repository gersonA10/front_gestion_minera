import 'package:front_gestion_minera/modules/partners/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/partners/domain/repositories/distributes_repository.dart';
import 'package:front_gestion_minera/modules/partners/domain/repositories/loan_history_repository.dart';
import 'package:front_gestion_minera/modules/partners/domain/repositories/partners_repository.dart';
import 'package:front_gestion_minera/modules/treasury/domain/repositories/treasury_repository.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/assistant/assistant_intent_parser.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/assistant/assistant_period_parser.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/assistant/assistant_service.dart';

/// Asistente del rol SOCIOS: sus aportes, sus dividendos, sus préstamos
/// y la transparencia financiera (reporte al que el rol ya tiene acceso).
class PartnersAssistantService
    with AssistantErrorHandler
    implements AssistantEngine {
  final PartnersRepository partnersRepository;
  final DistributesRepository distributesRepository;
  final LoanHistoryRepository loanHistoryRepository;
  final TreasuryRepository treasuryRepository;

  PartnersAssistantService({
    required this.partnersRepository,
    required this.distributesRepository,
    required this.loanHistoryRepository,
    required this.treasuryRepository,
  });

  static const List<String> _suggestions = [
    '¿Cuánto he aportado?',
    '¿Cuánto me toca de dividendos?',
    'Estado de mis préstamos',
    '¿En qué se gasta el dinero este mes?',
  ];

  @override
  String get welcomeText =>
      '¡Hola! Soy tu asistente. Pregúntame cuánto has aportado, cuánto te '
      'toca de dividendos, cómo van tus préstamos o en qué se gasta el '
      'dinero de la organización — escribiendo o dictando por voz.';

  @override
  List<String> get welcomeSuggestions => _suggestions;

  @override
  Future<AssistantReply> ask(String question) {
    return guarded(() async {
      final intent = AssistantIntentParser.parse(question);
      switch (intent) {
        case AssistantIntent.aportes:
          return await _aportes();
        case AssistantIntent.dividendos:
          return await _dividendos();
        case AssistantIntent.prestamos:
          return await _prestamos(question);
        case AssistantIntent.movimientosHoy:
        case AssistantIntent.reportes:
        case AssistantIntent.cajas:
          return await _transparencia(question);
        case AssistantIntent.oro:
        case AssistantIntent.ventas:
        case AssistantIntent.solicitudes:
          return const AssistantReply(
            text:
                'Esa información la gestiona tesorería. Lo que sí puedes '
                'ver es el reporte financiero de la organización: ingresos, '
                'egresos y en qué se gasta el dinero.',
            action: AssistantAction.abrirReportes,
            suggestions: _suggestions,
          );
        case AssistantIntent.ayuda:
        case AssistantIntent.saludo:
          return AssistantReply(
            text:
                '¡Hola! Puedo responderte al instante sobre tus finanzas '
                'como socio. Prueba con una de estas preguntas:',
            suggestions: welcomeSuggestions,
          );
        case AssistantIntent.desconocido:
          return const AssistantReply(
            text:
                'No entendí la pregunta. Puedo responder sobre tus aportes, '
                'tus dividendos, tus préstamos y el reporte financiero '
                '(ej. "¿en qué se gastó el dinero en mayo?").',
            suggestions: _suggestions,
          );
      }
    });
  }

  Future<AssistantReply> _aportes() async {
    final ContributionMetricsEntity m = await partnersRepository
        .getContributionMetrics();
    if (m.totalAportado <= 0) {
      return const AssistantReply(
        text: 'Aún no tienes aportes registrados.',
        suggestions: _suggestions,
      );
    }
    return AssistantReply(
      text:
          'Has aportado ${AssistantService.formatMoney(m.totalAportado)} en total.\n'
          '• Confirmado: ${AssistantService.formatMoney(m.totalConfirmado)}\n'
          '• Pendiente: ${AssistantService.formatMoney(m.totalPendiente)}',
      action: AssistantAction.abrirAportes,
      suggestions: const [
        '¿Cuánto me toca de dividendos?',
        'Estado de mis préstamos',
      ],
    );
  }

  Future<AssistantReply> _dividendos() async {
    final DistributesMetricsEntity m = await distributesRepository.getMetrics();
    if (m.totalDistribuido <= 0) {
      return const AssistantReply(
        text: 'Aún no tienes distribuciones de dividendos registradas.',
        suggestions: _suggestions,
      );
    }
    return AssistantReply(
      text:
          'Te han distribuido ${AssistantService.formatMoney(m.totalDistribuido)} en total.\n'
          '• Ya cobrado: ${AssistantService.formatMoney(m.totalPagado)}\n'
          '• Pendiente de cobro: ${AssistantService.formatMoney(m.totalPendiente)}',
      action: AssistantAction.abrirDistribuciones,
      suggestions: const ['¿Cuánto he aportado?', 'Estado de mis préstamos'],
    );
  }

  Future<AssistantReply> _prestamos(String question) async {
    final periodo = AssistantPeriodParser.parse(question);
    final m = await loanHistoryRepository.getMetrics(
      period: periodo?.period,
      exactDate: periodo?.exactDate,
    );
    final sinDinero = m.dinero.totalPrestado <= 0;
    final sinGramos = m.gramos.totalPrestado <= 0;
    if (sinDinero && sinGramos) {
      return const AssistantReply(
        text: 'No tienes préstamos registrados.',
        suggestions: _suggestions,
      );
    }
    final lineas = <String>[
      if (periodo != null)
        'Tus préstamos (${periodo.label}):'
      else
        'Tus préstamos:',
      if (!sinDinero)
        '• En dinero: pendiente ${AssistantService.formatMoney(m.dinero.totalPendiente)} '
            'de ${AssistantService.formatMoney(m.dinero.totalPrestado)} prestados '
            '(pagado ${AssistantService.formatMoney(m.dinero.totalPagado)}).',
      if (!sinGramos)
        '• En oro: pendiente ${AssistantService.formatGrams(m.gramos.totalPendiente)} '
            'de ${AssistantService.formatGrams(m.gramos.totalPrestado)} prestados '
            '(pagado ${AssistantService.formatGrams(m.gramos.totalPagado)}).',
    ];
    return AssistantReply(
      text: lineas.join('\n'),
      action: AssistantAction.abrirPrestamosSocio,
      suggestions: const [
        '¿Cuánto he aportado?',
        '¿Cuánto me toca de dividendos?',
      ],
    );
  }

  Future<AssistantReply> _transparencia(String question) async {
    final periodo = AssistantPeriodParser.parse(question);
    final report = await treasuryRepository.getFinancialReport(
      period: periodo?.period ?? 'month',
      exactDate: periodo?.exactDate,
    );
    final r = report.resumenGeneral;
    final label = periodo?.label ?? 'este mes';
    if (r.ingresosTotales == 0 && r.egresosTotales == 0) {
      return AssistantReply(
        text: 'No hay movimientos registrados en $label.',
        suggestions: _suggestions,
      );
    }
    final lineas = <String>[
      'Finanzas de la organización ($label):',
      '• Ingresos: ${AssistantService.formatMoney(r.ingresosTotales)}',
      '• Egresos: ${AssistantService.formatMoney(r.egresosTotales)}',
      '• Balance: ${AssistantService.formatMoney(r.balanceNeto)} (${r.estadoSalud})',
    ];
    final gastos = report.gastosPorResponsable;
    if (gastos.isNotEmpty) {
      lineas.add('El dinero se gastó en:');
      for (final g in gastos.take(4)) {
        lineas.add(
          '• ${g.area}: ${AssistantService.formatMoney(g.monto)} '
          '(${g.porcentajeDelTotal.toStringAsFixed(0)}%)',
        );
      }
    }
    return AssistantReply(
      text: lineas.join('\n'),
      action: AssistantAction.abrirReportes,
      suggestions: const [
        '¿Cuánto he aportado?',
        '¿Cuánto me toca de dividendos?',
      ],
    );
  }
}
