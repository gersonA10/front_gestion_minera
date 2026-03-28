import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_gestion_minera/config/router/app_router.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/widgets/logout_button_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/utils/greeting_util.dart';
import 'package:front_gestion_minera/utils/session/session_actions.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';

class _AppColors {
  static const primary = Color(0xFF1A56FF);
  static const primaryLight = Color(0xFFEEF2FF);
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

  const _MenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
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
        ),
        _MenuItem(
          title: 'Historial de Préstamos',
          subtitle: 'Seguimiento de cuotas',
          icon: Icons.receipt_long_rounded,
          accent: _AppColors.accentTeal,
          onTap: () => context.router.push(LoanHistoryRoute()),
        ),
        _MenuItem(
          title: 'Ingresos',
          subtitle: 'Entradas de capital',
          icon: Icons.trending_up_rounded,
          accent: _AppColors.accentGreen,
          onTap: () => context.router.push(DistributesRoute()),
        ),
        _MenuItem(
          title: 'Solicitar Dinero',
          subtitle: 'Solicitud de egreso',
          icon: Icons.payments_rounded,
          accent: _AppColors.accentOrange,
          onTap: () => context.router.push(MoneyRequestRoute()),
        ),
        _MenuItem(
          title: 'Historial de Aportes',
          subtitle: 'Contribuciones totales',
          icon: Icons.savings_rounded,
          accent: _AppColors.accentPurple,
          onTap: () => InjectorContainer.getIt<AppRouter>()
              .push(const ContributeHistoryRoute()),
        ),
        _MenuItem(
          title: 'Historial de Solicitudes',
          subtitle: 'Seguimiento de solicitud',
          icon: Icons.history_rounded,
          accent: _AppColors.accentRose,
          onTap: () => context.router.push(const RequestHistoryRoute()),
        ),
        _MenuItem(
          title: 'Bandeja de Socios',
          subtitle: 'Asistencia y actividades',
          icon: Icons.groups_2_rounded,
          accent: _AppColors.accentTeal,
          onTap: () {},
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final items = _buildMenuItems(context);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: _AppColors.background,
      body: FadeTransition(
        opacity: _fadeIn,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverHeader(context),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = items[index];
                    // Last item full width if odd count
                    return _MenuCard(
                      item: item,
                      delay: Duration(milliseconds: 60 * index),
                    );
                  },
                  childCount: items.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.05,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          color: _AppColors.surface,
          border: Border(
            bottom: BorderSide(color: _AppColors.border, width: 1),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: _AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Greeting + name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            GreetingUtil.getGreeting(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: _AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Text(
                            UserSession.userName,
                            style: const TextStyle(
                              fontSize: 15,
                              color: _AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Logout button
                    LogoutButton(),
                  ],
                ),

                const SizedBox(height: 20),
                const Text(
                  'Los Tigresito',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _AppColors.textPrimary,
                    letterSpacing: -0.6,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Gestión de socios financiero',
                  style: TextStyle(
                    fontSize: 13,
                    color: _AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Menu card ────────────────────────────────────────────────────────────────
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
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _AppColors.border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: _AppColors.cardShadow,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(widget.item.icon, color: accent, size: 22),
                  ),
                  const Spacer(),
                  // Title
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
                  // Subtitle
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
                  const SizedBox(height: 10),
                  // Accent bottom bar
                  Container(
                    height: 3,
                    width: 28,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(4),
                    ),
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