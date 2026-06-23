import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/camp/presentation/widgets/widgets.dart';
import 'package:front_gestion_minera/utils/greeting_util.dart';
import 'package:front_gestion_minera/utils/session/session_actions.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';
import 'package:front_gestion_minera/core/tutorial/tutorial_prefs.dart';
import 'package:front_gestion_minera/core/tutorial/tutorial_tts.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../domain/entity/entity.dart';
import '../bloc/camp_bloc.dart';

/// Paleta compartida con los módulos de socios y hacienda.
class _C {
  static const primary = Color(0xFF1A56FF);
  static const primaryDeep = Color(0xFF0B33B8);
  static const gold = Color(0xFFEFC805);
  static const background = Color(0xFFF5F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0D1B3E);
  static const textSecondary = Color(0xFF6B7A99);
  static const border = Color(0xFFE8EDF5);
}

/// Scope del recorrido guiado (coach marks) del módulo Campamento.
const String _kCampScope = 'camp_campamento';

/// Envuelve un widget como objetivo de coach mark con el estilo del módulo.
Widget _coachMark({
  required GlobalKey key,
  required String title,
  required String description,
  required Widget child,
}) {
  return Showcase(
    key: key,
    scope: _kCampScope,
    title: title,
    description: description,
    targetBorderRadius: BorderRadius.circular(20),
    targetPadding: const EdgeInsets.all(8),
    tooltipBackgroundColor: _C.surface,
    tooltipBorderRadius: BorderRadius.circular(16),
    titleTextStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      color: _C.textPrimary,
      letterSpacing: -0.2,
    ),
    descTextStyle: const TextStyle(
      fontSize: 13,
      height: 1.4,
      color: _C.textSecondary,
    ),
    child: child,
  );
}

@RoutePage()
class HomeDashboardCampScreen extends StatefulWidget {
  const HomeDashboardCampScreen({super.key});

  @override
  State<HomeDashboardCampScreen> createState() =>
      _HomeDashboardCampScreenState();
}

class _HomeDashboardCampScreenState extends State<HomeDashboardCampScreen> {
  late final CampBloc _campBloc;
  final ScrollController _scrollController = ScrollController();

  /// Número máximo de solicitudes que se muestran como "recientes".
  static const int _kRecentLimit = 5;

  // ─── Tutorial (coach marks) ───────────────────────────────────────────────
  /// Clave de rol para persistir si Campamento ya vio el recorrido guiado.
  static const String _kTutorialRoleKey = 'campamento';

  late final ShowcaseView _showcaseView;

  /// Evita re-evaluar el auto-inicio en cada rebuild del estado cargado.
  bool _tutorialAutoChecked = false;

  // Una key por objetivo. Viven en el State porque en showcaseview 5.x son
  // identificadores de registro.
  final GlobalKey _statsKey = GlobalKey();
  final GlobalKey _recentKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();

  /// Orden del recorrido (de arriba hacia abajo, para que el auto-scroll fluya).
  List<GlobalKey> get _showcaseKeys => [_statsKey, _recentKey, _fabKey];

  /// Locución de cada paso (mismo orden que [_showcaseKeys]).
  static const List<String> _speechByStep = [
    'Resumen del campamento. Aquí ves de un vistazo cuántas solicitudes están '
        'activas y cuántas ya se completaron.',
    'Solicitudes recientes. Son tus últimos movimientos: toca una para ver su '
        'detalle, o "Ver todas" para abrir el historial completo.',
    'Nueva solicitud. Con este botón registras una nueva solicitud de gasto o '
        'pago del campamento.',
  ];

  void _speakStep(int? index) {
    if (index == null || index < 0 || index >= _speechByStep.length) return;
    TutorialTts.instance.speak(_speechByStep[index]);
  }

  @override
  void initState() {
    super.initState();
    _campBloc = InjectorContainer.getIt<CampBloc>();
    _scrollController.addListener(_onScroll);
    _campBloc.add(GetCampDashboardEvent());

    _showcaseView = ShowcaseView.register(
      scope: _kCampScope,
      enableAutoScroll: true,
      onStart: (index, _) => _speakStep(index),
      onFinish: _markTutorialSeen,
      onDismiss: (_) => _markTutorialSeen(),
      globalTooltipActionConfig: const TooltipActionConfig(
        position: TooltipActionPosition.inside,
        alignment: MainAxisAlignment.spaceBetween,
      ),
      globalTooltipActions: [
        const TooltipActionButton(
          type: TooltipDefaultActionType.skip,
          name: 'Saltar',
          backgroundColor: Colors.transparent,
          textStyle: TextStyle(
            color: _C.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: 'Siguiente',
          backgroundColor: _C.primary,
          textStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  /// Inicia el recorrido la primera vez que el dashboard termina de cargar
  /// (antes los objetivos aún no están en el árbol).
  void _maybeAutoStartTutorial() {
    if (_tutorialAutoChecked) return;
    _tutorialAutoChecked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final alreadySeen = await TutorialPrefs.hasSeen(_kTutorialRoleKey);
      if (alreadySeen || !mounted) return;
      _startTutorial();
    });
  }

  void _startTutorial() {
    _showcaseView.startShowCase(
      _showcaseKeys,
      delay: const Duration(milliseconds: 500),
    );
  }

  void _markTutorialSeen() {
    TutorialTts.instance.stop();
    TutorialPrefs.markSeen(_kTutorialRoleKey);
  }

  @override
  void dispose() {
    TutorialTts.instance.stop();
    _showcaseView.unregister();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _campBloc.add(LoadMoreCampRequestsEvent());
    }
  }

  void _refresh() => _campBloc.add(GetCampDashboardEvent());

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _campBloc,
      child: Scaffold(
        backgroundColor: _C.background,
        body: BlocConsumer<CampBloc, CampState>(
          listener: (context, state) {
            if (state is CampDashboardLoaded) _maybeAutoStartTutorial();
          },
          builder: (context, state) {
            if (state is CampDashboardError) {
              return Column(
                children: [
                  const _Header(),
                  Expanded(
                    child: _ErrorView(message: state.message, onRetry: _refresh),
                  ),
                ],
              );
            }

            if (state is CampDashboardLoaded) {
              return RefreshIndicator(
                color: _C.primary,
                onRefresh: () async {
                  _refresh();
                  await Future.delayed(const Duration(milliseconds: 600));
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _Header(
                        active: state.stats.active,
                        completed: state.stats.completed,
                        statsKey: _statsKey,
                        onHelp: _startTutorial,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
                        child: _coachMark(
                          key: _recentKey,
                          title: 'Solicitudes recientes',
                          description:
                              'Tus últimos movimientos. Toca una para ver su '
                              'detalle o "Ver todas" para el historial completo.',
                          child: _RecentSection(
                            requests: state.requests,
                            total: state.totalRecords,
                            limit: _kRecentLimit,
                            onSeeAll: () =>
                                context.router.push(TransactionHistoryRoute()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // CampInitial / CampDashboardLoading
            return Column(
              children: const [
                _Header(),
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: _C.primary),
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: _coachMark(
          key: _fabKey,
          title: 'Nueva solicitud',
          description:
              'Registra una nueva solicitud de gasto o pago del campamento '
              'desde aquí.',
          child: FloatingActionButton.extended(
            onPressed: () async {
              final res = await context.router.push(const NewRequestRoute());
              if (res == true) _refresh();
            },
            backgroundColor: _C.primary,
            foregroundColor: Colors.white,
            elevation: 3,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Nueva Solicitud',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header con degradado curvo, círculos decorativos y estadísticas ─────────

class _Header extends StatelessWidget {
  /// Si [active]/[completed] son null, el header se dibuja sin las estadísticas
  /// (estados de carga/error).
  final int? active;
  final int? completed;

  /// Key del coach mark de las estadísticas (null = sin tutorial).
  final GlobalKey? statsKey;

  /// Si se provee, muestra el botón de ayuda que reabre el recorrido guiado.
  final VoidCallback? onHelp;

  const _Header({this.active, this.completed, this.statsKey, this.onHelp});

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  @override
  Widget build(BuildContext context) {
    final name = UserSession.userName.trim();
    final displayName = name.isNotEmpty ? name : 'Campamento';
    final showStats = active != null && completed != null;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_C.primary, _C.primaryDeep],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: _C.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -36,
            right: -28,
            child: _circle(140, Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            top: 44,
            right: 48,
            child: _circle(70, _C.gold.withValues(alpha: 0.18)),
          ),
          Positioned(
            bottom: -50,
            left: -30,
            child: _circle(120, Colors.white.withValues(alpha: 0.05)),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.cabin_rounded,
                          color: Colors.white,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              GreetingUtil.getGreeting(),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.75),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onHelp != null) ...[
                        _HeaderGlassIcon(
                          icon: Icons.help_outline_rounded,
                          onTap: onHelp!,
                        ),
                        const SizedBox(width: 10),
                      ],
                      const _GlassLogoutButton(),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Campamento',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.6,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _C.gold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Gestión de solicitudes y pagos',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.78),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (showStats) ...[
                    const SizedBox(height: 20),
                    if (statsKey != null)
                      _coachMark(
                        key: statsKey!,
                        title: 'Resumen del campamento',
                        description:
                            'De un vistazo: cuántas solicitudes están activas y '
                            'cuántas ya se completaron.',
                        child: _StatsRow(active: active!, completed: completed!),
                      )
                    else
                      _StatsRow(active: active!, completed: completed!),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int active;
  final int completed;

  const _StatsRow({required this.active, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatPill(
            icon: Icons.pending_actions_rounded,
            count: active,
            label: 'Activas',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatPill(
            icon: Icons.check_circle_rounded,
            count: completed,
            label: 'Completadas',
          ),
        ),
      ],
    );
  }
}

class _HeaderGlassIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderGlassIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.28),
            width: 1,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;

  const _StatPill({
    required this.icon,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.0,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassLogoutButton extends StatefulWidget {
  const _GlassLogoutButton();

  @override
  State<_GlassLogoutButton> createState() => _GlassLogoutButtonState();
}

class _GlassLogoutButtonState extends State<_GlassLogoutButton> {
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressing = true),
      onTapUp: (_) {
        setState(() => _pressing = false);
        SessionActions.logout();
      },
      onTapCancel: () => setState(() => _pressing = false),
      child: AnimatedScale(
        scale: _pressing ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.28),
              width: 1,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout_rounded, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text(
                'Salir',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sección de solicitudes recientes ───────────────────────────────────────

class _RecentSection extends StatelessWidget {
  final List<CampRecentRequestEntity> requests;
  final int total;
  final int limit;
  final VoidCallback onSeeAll;

  const _RecentSection({
    required this.requests,
    required this.total,
    required this.limit,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final visibleCount = requests.length > limit ? limit : requests.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          'Solicitudes recientes',
          helper: total > 0 ? '$total' : null,
          onSeeAll: requests.isEmpty ? null : onSeeAll,
        ),
        const SizedBox(height: 12),
        if (requests.isEmpty)
          const _EmptyRequests()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: visibleCount,
            itemBuilder: (context, index) =>
                CardRequestsWidget(request: requests[index]),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final String? helper;
  final VoidCallback? onSeeAll;

  const _SectionTitle(this.text, {this.helper, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _C.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        if (helper != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _C.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              helper!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _C.primary,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            behavior: HitTestBehavior.opaque,
            child: const Text(
              'Ver todas',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _C.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyRequests extends StatelessWidget {
  const _EmptyRequests();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _C.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_rounded,
              size: 32,
              color: _C.primary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Sin solicitudes recientes',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Crea tu primera solicitud con el botón "Nueva Solicitud".',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: _C.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 52,
              color: Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: _C.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
