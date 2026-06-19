import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_gestion_minera/config/router/app_router.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/tutorial/tutorial_prefs.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/utils/greeting_util.dart';
import 'package:front_gestion_minera/utils/session/session_actions.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';
import 'package:showcaseview/showcaseview.dart';

class _AppColors {
  static const primary = Color(0xFF1A56FF);
  static const primaryDeep = Color(0xFF0B33B8);
  static const gold = Color(0xFFEFC805);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF5F7FB);
  static const textPrimary = Color(0xFF0D1B3E);
  static const textSecondary = Color(0xFF6B7A99);

  static const border = Color(0xFFE8EDF5);
  static const cardShadow = Color(0x0A1A56FF);

  static const accentGreen = Color(0xFF00C896);
  static const accentOrange = Color(0xFFFF8C42);
  static const accentPurple = Color(0xFF7C5CBF);
  static const accentTeal = Color(0xFF00B4D8);
  static const accentRose = Color(0xFFE83E8C);
}

class _MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  final VoidCallback onTap;

  /// Título del coach mark (tutorial) para esta tarjeta.
  final String tutorialTitle;

  /// Descripción del coach mark: qué es y qué puede hacer el socio aquí.
  final String tutorialDescription;

  const _MenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
    required this.tutorialTitle,
    required this.tutorialDescription,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────
@RoutePage()
class PartnersScreen extends StatefulWidget {
  final String nombre;
  const PartnersScreen({super.key, required this.nombre});

  @override
  State<PartnersScreen> createState() => _PartnersScreenState();
}

class _PartnersScreenState extends State<PartnersScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  // ─── Tutorial (coach marks) ───────────────────────────────────────────────
  /// Clave de rol para persistir si el socio ya vio el recorrido guiado.
  static const String _kTutorialRoleKey = 'socios';

  /// Scope propio del recorrido de esta pantalla (evita choques con otros).
  static const String _kShowcaseScope = 'partners_socios';

  /// Cantidad de tarjetas del menú (debe coincidir con [_buildMenuItems]).
  static const int _kMenuCount = 8;

  late final ShowcaseView _showcaseView;

  /// Una key por tarjeta. En showcaseview 5.x estas keys son identificadores
  /// de registro (no se adjuntan al widget), por eso viven en el State.
  final List<GlobalKey> _showcaseKeys =
      List.generate(_kMenuCount, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _showcaseView = ShowcaseView.register(
      scope: _kShowcaseScope,
      enableAutoScroll: true,
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
            color: _AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: 'Siguiente',
          backgroundColor: _AppColors.primary,
          textStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    // Lanza el recorrido la primera vez, tras pintar y dejar asentar la
    // animación de entrada de las tarjetas.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartTutorial());
  }

  Future<void> _maybeStartTutorial() async {
    final alreadySeen = await TutorialPrefs.hasSeen(_kTutorialRoleKey);
    if (alreadySeen || !mounted) return;
    _startTutorial();
  }

  void _startTutorial() {
    _showcaseView.startShowCase(
      _showcaseKeys,
      delay: const Duration(milliseconds: 700),
    );
  }

  void _markTutorialSeen() {
    TutorialPrefs.markSeen(_kTutorialRoleKey);
  }

  @override
  void dispose() {
    _showcaseView.unregister();
    _controller.dispose();
    super.dispose();
  }

  List<_MenuItem> _buildMenuItems(BuildContext context) => [
    _MenuItem(
      title: 'Registrar Préstamo',
      subtitle: 'Nueva solicitud',
      icon: Icons.add_card_rounded,
      accent: _AppColors.primary,
      onTap: () => InjectorContainer.getIt<AppRouter>().push(LoanRoute()),
      tutorialTitle: 'Registrar Préstamo',
      tutorialDescription:
          'Crea aquí una nueva solicitud de préstamo: defines el monto y las '
          'condiciones para pedir dinero al fondo de socios.',
    ),
    _MenuItem(
      title: 'Historial de Préstamos',
      subtitle: 'Seguimiento de cuotas',
      icon: Icons.receipt_long_rounded,
      accent: _AppColors.accentTeal,
      onTap: () => context.router.push(LoanHistoryRoute()),
      tutorialTitle: 'Historial de Préstamos',
      tutorialDescription:
          'Consulta tus préstamos activos y pagados, y haz seguimiento al '
          'estado de cada cuota.',
    ),
    _MenuItem(
      title: 'Ingresos',
      subtitle: 'Entradas de capital',
      icon: Icons.trending_up_rounded,
      accent: _AppColors.accentGreen,
      onTap: () => context.router.push(DistributesRoute()),
      tutorialTitle: 'Ingresos',
      tutorialDescription:
          'Revisa las entradas de capital y los ingresos registrados a tu '
          'favor dentro del fondo.',
    ),
    _MenuItem(
      title: 'Solicitar Dinero',
      subtitle: 'Solicitud de egreso',
      icon: Icons.payments_rounded,
      accent: _AppColors.accentOrange,
      onTap: () => context.router.push(MoneyRequestRoute()),
      tutorialTitle: 'Solicitar Dinero',
      tutorialDescription:
          'Pide un egreso o retiro de dinero. Tu solicitud queda registrada '
          'para su revisión y aprobación.',
    ),
    _MenuItem(
      title: 'Historial de Aportes',
      subtitle: 'Contribuciones totales',
      icon: Icons.savings_rounded,
      accent: _AppColors.accentPurple,
      onTap: () => InjectorContainer.getIt<AppRouter>().push(
        const ContributeHistoryRoute(),
      ),
      tutorialTitle: 'Historial de Aportes',
      tutorialDescription:
          'Mira el total de tus contribuciones al fondo y el detalle de cada '
          'aporte que has realizado.',
    ),
    _MenuItem(
      title: 'Historial de Solicitudes',
      subtitle: 'Seguimiento de solicitud',
      icon: Icons.history_rounded,
      accent: _AppColors.accentRose,
      onTap: () => context.router.push(const RequestHistoryRoute()),
      tutorialTitle: 'Historial de Solicitudes',
      tutorialDescription:
          'Sigue el estado de todas tus solicitudes: pendientes, aprobadas o '
          'rechazadas.',
    ),
    _MenuItem(
      title: 'Bandeja de Socios',
      subtitle: 'Asistencia y actividades',
      icon: Icons.groups_2_rounded,
      accent: _AppColors.accentTeal,
      onTap: () => context.router.push(const MemberSectionRoute()),
      tutorialTitle: 'Bandeja de Socios',
      tutorialDescription:
          'Aquí llegan tus reuniones y memorandos. Mantente al día con la '
          'asistencia y las actividades de los socios.',
    ),
    _MenuItem(
      title: 'Reportes',
      subtitle: 'Reportes de actividades',
      icon: Icons.notes_sharp,
      accent: _AppColors.textPrimary,
      onTap: () {
        context.router.push(FinancialReportsRoute());
      },
      tutorialTitle: 'Reportes',
      tutorialDescription:
          'Genera y consulta reportes de tus actividades financieras como '
          'socio.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = _buildMenuItems(context);
    assert(
      items.length == _showcaseKeys.length,
      'El número de tarjetas (${items.length}) debe coincidir con '
      '_kMenuCount ($_kMenuCount) para alinear los coach marks.',
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: _AppColors.background,
      body: FadeTransition(
        opacity: _fadeIn,
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            _GradientHeader(onHelp: _startTutorial),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(22, 22, 22, 12),
                child: Text(
                  'Accesos rápidos',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = items[index];
                  return Showcase(
                    key: _showcaseKeys[index],
                    scope: _kShowcaseScope,
                    title: item.tutorialTitle,
                    description: item.tutorialDescription,
                    targetBorderRadius: BorderRadius.circular(22),
                    targetPadding: const EdgeInsets.all(6),
                    tooltipBackgroundColor: _AppColors.surface,
                    tooltipBorderRadius: BorderRadius.circular(16),
                    titleTextStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    descTextStyle: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: _AppColors.textSecondary,
                    ),
                    child: _MenuCard(
                      item: item,
                      delay: Duration(milliseconds: 60 * index),
                    ),
                  );
                }, childCount: items.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.02,
                ),
              ),
            ),
          
          ],
        ),
      ),
    );
  }
}

// ─── Header con degradado curvo y decoración ───────────────────────────────────

class _GradientHeader extends StatelessWidget {
  const _GradientHeader({required this.onHelp});

  /// Reabre el tutorial (coach marks) cuando el socio toca el botón de ayuda.
  final VoidCallback onHelp;

  Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_AppColors.primary, _AppColors.primaryDeep],
          ),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: _AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Círculos decorativos
            Positioned(
              top: -36,
              right: -28,
              child: _circle(140, Colors.white.withValues(alpha: 0.08)),
            ),
            Positioned(
              top: 44,
              right: 48,
              child: _circle(70, _AppColors.gold.withValues(alpha: 0.18)),
            ),
            Positioned(
              bottom: -50,
              left: -30,
              child: _circle(120, Colors.white.withValues(alpha: 0.05)),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top bar
                    Row(
                      children: [
                        // Avatar glass
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
                            Icons.account_balance_rounded,
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
                                UserSession.userName,
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
                        _GlassIconButton(
                          icon: Icons.help_outline_rounded,
                          tooltip: 'Ver tutorial',
                          onTap: onHelp,
                        ),
                        const SizedBox(width: 8),
                        const _GlassLogoutButton(),
                      ],
                    ),

                    const SizedBox(height: 22),
                    const Text(
                      'Tigres Dorados',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.6,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Acento dorado
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _AppColors.gold,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Gestión de socios financiero',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Botón glass de ícono (sobre el header de color) ────────────────────────────

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
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

    if (tooltip == null) return button;
    return Tooltip(message: tooltip, child: button);
  }
}

// ─── Logout estilo glass (sobre el header de color) ─────────────────────────────

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

// ─── Tarjeta de menú ────────────────────────────────────────────────────────────

class _MenuCard extends StatefulWidget {
  final _MenuItem item;
  final Duration delay;

  const _MenuCard({required this.item, required this.delay});

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard>
    with SingleTickerProviderStateMixin {
  bool _pressing = false;
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryAnim;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _entryAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    Future.delayed(widget.delay, () {
      if (mounted) _entryCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.item.accent;

    return FadeTransition(
      opacity: _entryAnim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(_entryAnim),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressing = true),
          onTapUp: (_) {
            setState(() => _pressing = false);
            widget.item.onTap();
          },
          onTapCancel: () => setState(() => _pressing = false),
          child: AnimatedScale(
            scale: _pressing ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: Container(
              decoration: BoxDecoration(
                color: _AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _AppColors.border, width: 1),
                boxShadow: [
                  // Glow tenue del color de acento
                  BoxShadow(
                    color: accent.withValues(alpha: 0.14),
                    blurRadius: 18,
                    spreadRadius: -4,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: _AppColors.cardShadow,
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge de ícono con degradado + glow
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              accent,
                              Color.lerp(accent, Colors.white, 0.28)!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.item.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      // Chevron
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: accent,
                          size: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    widget.item.title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: _AppColors.textPrimary,
                      height: 1.25,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.item.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
