import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_route_observer.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/widgets/logout_button_widget.dart';
import 'package:front_gestion_minera/core/tutorial/tutorial_prefs.dart';
import 'package:front_gestion_minera/core/tutorial/tutorial_tts.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/machinery/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/bloc/machinery_bloc.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/machinery_signals.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/widgets/widgets.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';
import 'package:showcaseview/showcaseview.dart';

/// Scope del recorrido guiado (coach marks) del módulo Maquinaria.
const String _kMachineryScope = 'machinery_maquinaria';

/// Envuelve un widget como objetivo de coach mark con el estilo del módulo.
Widget _coachMark({
  required GlobalKey key,
  required String title,
  required String description,
  required Widget child,
}) {
  return Showcase(
    key: key,
    scope: _kMachineryScope,
    title: title,
    description: description,
    targetBorderRadius: BorderRadius.circular(20),
    targetPadding: const EdgeInsets.all(8),
    tooltipBackgroundColor: TColors.white,
    tooltipBorderRadius: BorderRadius.circular(16),
    titleTextStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      color: TColors.textPrimary,
      letterSpacing: -0.2,
    ),
    descTextStyle: const TextStyle(
      fontSize: 13,
      height: 1.4,
      color: TColors.textSecondary,
    ),
    child: child,
  );
}

@RoutePage()
class HomeMachinaryScreen extends StatefulWidget {
  const HomeMachinaryScreen({super.key});

  @override
  State<HomeMachinaryScreen> createState() => _HomeMachinaryScreenState();
}

class _HomeMachinaryScreenState extends State<HomeMachinaryScreen>
    with RouteAware {
  String rol = 'cargando...';

  late final MachineryBloc _machineryBloc;
  MetricsMachineryEntity? _cacheMetrics;
  List<MachineryEntity>? _cacheinventory;

  // ─── Tutorial (coach marks) ───────────────────────────────────────────────
  /// Clave de rol para persistir si Maquinaria ya vio el recorrido guiado.
  static const String _kTutorialRoleKey = 'maquinaria';

  late final ShowcaseView _showcaseView;

  /// Evita re-evaluar el auto-inicio en cada rebuild del estado cargado.
  bool _tutorialAutoChecked = false;

  final GlobalKey _healthKey = GlobalKey();
  final GlobalKey _inventoryKey = GlobalKey();
  final GlobalKey _registerKey = GlobalKey();

  /// Orden del recorrido (de arriba hacia abajo).
  List<GlobalKey> get _showcaseKeys =>
      [_healthKey, _inventoryKey, _registerKey];

  /// Locución de cada paso (mismo orden que [_showcaseKeys]).
  static const List<String> _speechByStep = [
    'Estado de la flota. La salud de tu maquinaria de un vistazo: cuántas están '
        'operativas, en mantenimiento o inactivas. Toca cada estado para ver '
        'esas máquinas.',
    'Inventario reciente. Tus últimas máquinas registradas; toca "Ver todos" '
        'para abrir la lista completa.',
    'Registrar nueva máquina. Con este botón das de alta una nueva máquina en '
        'la flota.',
  ];

  void _speakStep(int? index) {
    if (index == null || index < 0 || index >= _speechByStep.length) return;
    TutorialTts.instance.speak(_speechByStep[index]);
  }

  Future<void> _loadUserData() async {
    final role = await UserSession.getRole();
    setState(() {
      rol = role;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    machineryStatusChangedSignal.addListener(_onStatusSignal);
    // Métricas e inventario en paralelo (más rápido que encadenarlos).
    _machineryBloc = InjectorContainer.getIt<MachineryBloc>()
      ..add(FetchMetricsMachineEvent())
      ..add(ListInventoryMachineryEvent());

    _showcaseView = ShowcaseView.register(
      scope: _kMachineryScope,
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
            color: TColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: 'Siguiente',
          backgroundColor: TColors.appMainColor,
          textStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  /// Inicia el recorrido la primera vez que métricas e inventario ya cargaron
  /// (antes los objetivos aún no están en el árbol; hay un skeleton).
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // Confirmación en segundo plano al volver (la UI ya se actualizó de forma
    // optimista vía la señal si hubo un cambio de estado).
    _loadData();
  }

  @override
  void dispose() {
    TutorialTts.instance.stop();
    _showcaseView.unregister();
    machineryStatusChangedSignal.removeListener(_onStatusSignal);
    appRouteObserver.unsubscribe(this);
    // El bloc viene de un `registerFactory` y se inyecta con `BlocProvider.value`,
    // que no lo cierra; lo cerramos aquí para no fugar la instancia.
    _machineryBloc.close();
    super.dispose();
  }

  /// Dispara la carga de métricas + inventario en paralelo.
  void _loadData() {
    _machineryBloc
      ..add(FetchMetricsMachineEvent())
      ..add(ListInventoryMachineryEvent());
  }

  /// Recarga métricas + inventario (en paralelo) y espera a que el bloc emita
  /// un estado terminal para cerrar el indicador de refresco. Se acota con un
  /// timeout para que el spinner no quede girando si el bloc no emite (p. ej.
  /// sesión expirada, que termina sin emitir estado).
  Future<void> _onRefresh() async {
    _loadData();
    try {
      await _machineryBloc.stream
          .firstWhere(
            (state) =>
                state is InventoryMachineryLoaded ||
                state is MetricsMachineryError ||
                state is InventoryMachineryError,
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      // Timeout o cierre del stream: cerramos el indicador igualmente.
    }
  }

  /// Aplica de inmediato un cambio de estado recibido por la señal global:
  /// actualiza la tarjeta del inventario y recalcula los contadores, sin
  /// esperar a la recarga de red.
  void _onStatusSignal() {
    final change = machineryStatusChangedSignal.value;
    if (change == null) return;
    final inv = _cacheinventory;
    final metrics = _cacheMetrics;
    if (inv == null || metrics == null) return;

    final idx = inv.indexWhere((m) => m.machineId == change.machineId);
    if (idx == -1) return; // No está en la lista cargada; el refetch lo corrige.

    final old = inv[idx];
    if (_statusKey(old.status) == _statusKey(change.status)) return;

    _bumpMetric(metrics, old.status, -1);
    _bumpMetric(metrics, change.status, 1);
    inv[idx] = MachineryEntity(
      machineId: old.machineId,
      uniqueCode: old.uniqueCode,
      name: old.name,
      type: old.type,
      status: change.status,
      description: old.description,
      photoUrl: old.photoUrl,
      lastMaintenance: old.lastMaintenance,
      registeredAt: old.registeredAt,
    );
    if (mounted) setState(() {});
  }

  String _statusKey(String s) => s.trim().toUpperCase();

  void _bumpMetric(MetricsMachineryEntity m, String status, int delta) {
    switch (_statusKey(status)) {
      case 'ACTIVO':
        m.operationalMachines = _nonNeg(m.operationalMachines + delta);
        break;
      case 'EN MANTENIMIENTO':
        m.underMaintenance = _nonNeg(m.underMaintenance + delta);
        break;
      case 'INACTIVO':
        m.inactiveMachines = _nonNeg(m.inactiveMachines + delta);
        break;
    }
  }

  int _nonNeg(int v) => v < 0 ? 0 : v;

  void _goToList([String? status]) =>
      context.router.push(ListMachineryRoute(initialStatus: status));

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _machineryBloc,
      child: Scaffold(
        backgroundColor: TColors.background,
        body: BlocConsumer<MachineryBloc, MachineryState>(
          listenWhen: (previous, current) =>
              current is MetricsMachineryLoaded ||
              current is InventoryMachineryLoaded,
          listener: (context, state) {
            if (state is MetricsMachineryLoaded) {
              _cacheMetrics = state.metrics;
            } else if (state is InventoryMachineryLoaded) {
              _cacheinventory = state.machinery;
            }
            if (_cacheMetrics != null && _cacheinventory != null) {
              _maybeAutoStartTutorial();
            }
          },
          buildWhen: (previous, current) =>
              current is MetricsMachineryLoading ||
              current is MetricsMachineryLoaded ||
              current is MetricsMachineryError ||
              current is InventoryMachineryLoaded ||
              current is InventoryMachineryLoading ||
              current is InventoryMachineryError,
          builder: (context, state) {
            if (state is MetricsMachineryError && _cacheMetrics == null) {
              return SafeArea(child: _buildErrorState(state.message));
            }
            if (state is InventoryMachineryError && _cacheinventory == null) {
              return SafeArea(child: _buildErrorState(state.message));
            }
            if (_cacheMetrics == null || _cacheinventory == null) {
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle.light,
                child: _HomeSkeleton(userName: UserSession.userName),
              );
            }

            final metrics = _cacheMetrics!;
            final inventory = _cacheinventory!;
            final bottomInset = MediaQuery.of(context).padding.bottom;
            final needsAttention =
                metrics.underMaintenance + metrics.inactiveMachines;

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light,
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: TColors.appMainColor,
                backgroundColor: TColors.white,
                displacement: MediaQuery.of(context).padding.top + 24,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _FleetHero(
                        userName: UserSession.userName,
                        rol: rol,
                        onHelp: _startTutorial,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                        child: _coachMark(
                          key: _healthKey,
                          title: 'Estado de la flota',
                          description:
                              'La salud de tu maquinaria de un vistazo. Toca '
                              'un estado para ver esas máquinas.',
                          child: _FleetHealthCard(
                            metrics: metrics,
                            onStatusTap: _goToList,
                          ),
                        ),
                      ),
                    ),
                    if (needsAttention > 0)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                          child: _AttentionBanner(
                            count: needsAttention,
                            critical: metrics.inactiveMachines > 0,
                            onTap: () => _goToList(
                              metrics.inactiveMachines > 0
                                  ? 'INACTIVO'
                                  : 'EN MANTENIMIENTO',
                            ),
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        child: _coachMark(
                          key: _inventoryKey,
                          title: 'Inventario reciente',
                          description:
                              'Tus últimas máquinas registradas; toca "Ver '
                              'todos" para la lista completa.',
                          child: _SectionHeader(
                            title: 'Inventario reciente',
                            count: inventory.length,
                            onSeeAll: _goToList,
                          ),
                        ),
                      ),
                    ),
                    if (inventory.isEmpty)
                      const SliverToBoxAdapter(child: _EmptyInventory())
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => CardMachineryWidget(
                              machine: inventory[index],
                            ),
                            childCount:
                                inventory.length <= 5 ? inventory.length : 5,
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            EdgeInsets.fromLTRB(20, 14, 20, 28 + bottomInset),
                        child: _coachMark(
                          key: _registerKey,
                          title: 'Registrar nueva máquina',
                          description:
                              'Da de alta una nueva máquina en la flota desde '
                              'aquí.',
                          child: _RegisterMachineButton(
                            // Tras registrar, refrescamos métricas e inventario
                            // para que la nueva máquina aparezca de inmediato.
                            onRegistered: _loadData,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          decoration: BoxDecoration(
            color: TColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: TColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: TColors.dangerLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  color: TColors.danger,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No se pudo cargar la información',
                style: TextStyle(
                  color: TColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loadData,
                  style: FilledButton.styleFrom(
                    backgroundColor: TColors.appMainColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: const Text(
                    'Reintentar',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Encabezado inmersivo: el color llega hasta el borde superior, detrás de la
/// hora y la batería. Solo saludo + rol + cerrar sesión.
class _FleetHero extends StatelessWidget {
  final String userName;
  final String rol;

  /// Si se provee, muestra el botón de ayuda que reabre el recorrido guiado.
  final VoidCallback? onHelp;

  const _FleetHero({required this.userName, required this.rol, this.onHelp});

  String get _firstName {
    final trimmed = userName.trim();
    if (trimmed.isEmpty) return 'Usuario';
    return trimmed.split(' ').first;
  }

  String get _roleLabel =>
      rol == 'jefe_maquinas' ? 'Jefe de Máquinas' : 'Operaciones';

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [TColors.appMainDarkColor, TColors.appMainColor],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: TColors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.engineering_rounded,
                    color: TColors.white,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, $_firstName',
                        style: const TextStyle(
                          color: TColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _roleLabel,
                        style: TextStyle(
                          color: TColors.white.withValues(alpha: 0.75),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onHelp != null) ...[
                  GestureDetector(
                    onTap: onHelp!,
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: TColors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.help_outline_rounded,
                        color: TColors.white,
                        size: 21,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                const LogoutButton(),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Este es el estado de tu maquinaria hoy.',
              style: TextStyle(
                color: TColors.white.withValues(alpha: 0.8),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta principal: gráfico de dona con la salud de la flota + leyenda
/// desglosada. Comunica de un vistazo cuántas máquinas hay y en qué estado.
class _FleetHealthCard extends StatelessWidget {
  final MetricsMachineryEntity metrics;
  final void Function(String status) onStatusTap;

  const _FleetHealthCard({required this.metrics, required this.onStatusTap});

  @override
  Widget build(BuildContext context) {
    final total = metrics.total;
    int pct(int v) => total == 0 ? 0 : ((v / total) * 100).round();

    final hasAlert = metrics.operationalMachines < total;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TColors.border),
        boxShadow: const [
          BoxShadow(
            color: TColors.cardShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Estado de la flota',
                style: TextStyle(
                  color: TColors.textPrimary,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: hasAlert
                      ? TColors.warningLight
                      : TColors.successLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hasAlert ? 'Requiere revisión' : 'Todo en orden',
                  style: TextStyle(
                    color: hasAlert ? TColors.warning : TColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _FleetDonut(
                total: total,
                operational: metrics.operationalMachines,
                maintenance: metrics.underMaintenance,
                inactive: metrics.inactiveMachines,
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  children: [
                    _LegendRow(
                      color: TColors.success,
                      label: 'Operativas',
                      count: metrics.operationalMachines,
                      percent: pct(metrics.operationalMachines),
                      onTap: () => onStatusTap('ACTIVO'),
                    ),
                    const SizedBox(height: 4),
                    _LegendRow(
                      color: TColors.warning,
                      label: 'En mantenimiento',
                      count: metrics.underMaintenance,
                      percent: pct(metrics.underMaintenance),
                      onTap: () => onStatusTap('EN MANTENIMIENTO'),
                    ),
                    const SizedBox(height: 4),
                    _LegendRow(
                      color: TColors.danger,
                      label: 'Inactivas',
                      count: metrics.inactiveMachines,
                      percent: pct(metrics.inactiveMachines),
                      onTap: () => onStatusTap('INACTIVO'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Anillo de dona dibujado a mano con el total en el centro.
class _FleetDonut extends StatelessWidget {
  static const double _size = 116;

  final int total;
  final int operational;
  final int maintenance;
  final int inactive;

  const _FleetDonut({
    required this.total,
    required this.operational,
    required this.maintenance,
    required this.inactive,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(_size),
            painter: _DonutPainter(
              operational: operational,
              maintenance: maintenance,
              inactive: inactive,
              stroke: 13,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                total.toString(),
                style: const TextStyle(
                  color: TColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'máquinas',
                style: TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final int operational;
  final int maintenance;
  final int inactive;
  final double stroke;

  _DonutPainter({
    required this.operational,
    required this.maintenance,
    required this.inactive,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;

    // Pista de fondo.
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = TColors.border;
    canvas.drawCircle(center, radius, track);

    final total = operational + maintenance + inactive;
    if (total == 0) return;

    final segments = <MapEntry<int, Color>>[
      MapEntry(operational, TColors.success),
      MapEntry(maintenance, TColors.warning),
      MapEntry(inactive, TColors.danger),
    ].where((e) => e.key > 0).toList();

    const gap = 0.06; // separación entre segmentos (radianes)
    final totalGap = segments.length > 1 ? gap * segments.length : 0.0;
    final available = (2 * math.pi) - totalGap;
    double start = -math.pi / 2 + (segments.length > 1 ? gap / 2 : 0);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    for (final seg in segments) {
      final sweep = (seg.key / total) * available;
      paint.color = seg.value;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.operational != operational ||
      old.maintenance != maintenance ||
      old.inactive != inactive;
}

/// Fila de leyenda: punto de color + etiqueta + conteo + porcentaje.
/// Tocarla abre el listado ya filtrado por ese estado.
class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  final int percent;
  final VoidCallback onTap;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.count,
    required this.percent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: TColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              count.toString(),
              style: const TextStyle(
                color: TColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(
              width: 38,
              child: Text(
                '$percent%',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: TColors.iconMuted,
            ),
          ],
        ),
      ),
    );
  }
}

/// Aviso accionable cuando hay máquinas que requieren revisión.
class _AttentionBanner extends StatelessWidget {
  final int count;
  final bool critical;
  final VoidCallback onTap;

  const _AttentionBanner({
    required this.count,
    required this.critical,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = critical ? TColors.danger : TColors.warning;
    final accentBg = critical ? TColors.dangerLight : TColors.warningLight;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.28)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accentBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.warning_amber_rounded, color: accent, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Atención requerida',
                    style: TextStyle(
                      color: TColors.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count == 1
                        ? '1 máquina necesita revisión'
                        : '$count máquinas necesitan revisión',
                    style: const TextStyle(
                      color: TColors.textSecondary,
                      fontSize: 12.5,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: accent, size: 14),
          ],
        ),
      ),
    );
  }
}

/// Cabecera de sección con título, contador y acción "Ver todos".
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onSeeAll;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              color: TColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: TColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: TColors.appMainColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: const [
              Text(
                'Ver todos',
                style: TextStyle(
                  color: TColors.appMainColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 2),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: TColors.appMainColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Botón principal para registrar nueva maquinaria.
class _RegisterMachineButton extends StatelessWidget {
  final VoidCallback onRegistered;

  const _RegisterMachineButton({required this.onRegistered});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: () async {
          final response =
              await context.router.push(RegistrationOfNewMachineryRoute());
          if (response == true) {
            onRegistered();
          }
        },
        style: FilledButton.styleFrom(
          backgroundColor: TColors.appMainDarkColor,
          foregroundColor: TColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'Registrar Nueva Máquina',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// Estado vacío del inventario.
class _EmptyInventory extends StatelessWidget {
  const _EmptyInventory();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: TColors.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: TColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.precision_manufacturing_rounded,
                color: TColors.appMainColor,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Sin maquinaria registrada',
              style: TextStyle(
                color: TColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Registra tu primera máquina para comenzar a gestionar la flota.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton de carga inicial que refleja la estructura real del home
/// (hero, tarjeta de salud con dona y leyenda, inventario y botón).
class _HomeSkeleton extends StatefulWidget {
  final String userName;

  const _HomeSkeleton({required this.userName});

  @override
  State<_HomeSkeleton> createState() => _HomeSkeletonState();
}

class _HomeSkeletonState extends State<_HomeSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();
  late final Animation<double> _a =
      CurvedAnimation(parent: _ac, curve: Curves.easeInOut);

  String get _firstName {
    final trimmed = widget.userName.trim();
    if (trimmed.isEmpty) return 'Usuario';
    return trimmed.split(' ').first;
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return AnimatedBuilder(
      animation: _a,
      builder: (_, _) {
        final gray = Color.lerp(
          const Color(0xFFEAEDF2),
          const Color(0xFFF6F8FB),
          _a.value,
        )!;
        final onHero = TColors.white.withValues(alpha: 0.12 + 0.14 * _a.value);

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [TColors.appMainDarkColor, TColors.appMainColor],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: TColors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.engineering_rounded,
                              color: TColors.white,
                              size: 23,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hola, $_firstName',
                                  style: const TextStyle(
                                    color: TColors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                _bone(onHero, width: 96, height: 11, radius: 5),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _bone(onHero, width: 200, height: 12, radius: 6),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tarjeta de salud (dona + leyenda).
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: TColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: TColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _bone(gray, width: 140, height: 14, radius: 6),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                width: 116,
                                height: 116,
                                decoration: BoxDecoration(
                                  color: gray,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 22),
                              Expanded(
                                child: Column(
                                  children: [
                                    _legendBone(gray),
                                    const SizedBox(height: 14),
                                    _legendBone(gray),
                                    const SizedBox(height: 14),
                                    _legendBone(gray),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _bone(gray, width: 150, height: 18, radius: 6),
                        const Spacer(),
                        _bone(gray, width: 64, height: 13, radius: 6),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _cardBone(gray),
                    _cardBone(gray),
                    _cardBone(gray),
                    const SizedBox(height: 2),
                    _bone(gray, width: double.infinity, height: 54, radius: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bone(
    Color c, {
    required double width,
    required double height,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _legendBone(Color c) {
    return Row(
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: _bone(c, width: double.infinity, height: 11, radius: 5)),
      ],
    );
  }

  Widget _cardBone(Color c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TColors.border),
      ),
      child: Row(
        children: [
          _bone(c, width: 64, height: 64, radius: 14),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bone(c, width: 150, height: 13, radius: 6),
                const SizedBox(height: 8),
                _bone(c, width: 110, height: 11, radius: 6),
                const SizedBox(height: 12),
                _bone(c, width: 80, height: 18, radius: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
