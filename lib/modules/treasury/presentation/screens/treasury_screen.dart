import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/utils/greeting_util.dart';
import 'package:front_gestion_minera/utils/session/session_actions.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';
import '../bloc/treasury_bloc.dart';

class _C {
  static const primary = Color(0xFF1A56FF);
  static const primaryDeep = Color(0xFF0B33B8);
  static const gold = Color(0xFFEFC805);
  static const goldDeep = Color(0xFFB8930A);
  static const background = Color(0xFFF5F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0D1B3E);
  static const textSecondary = Color(0xFF6B7A99);
  static const border = Color(0xFFE8EDF5);
  static const amber = Color(0xFFC47A00);
  static const green = Color(0xFF0F9D8A);
  static const purple = Color(0xFF7C5CBF);
}

class _Module {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  const _Module({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });
}

class _Section {
  final String label;
  final List<_Module> items;
  const _Section(this.label, this.items);
}

@RoutePage()
class TreasuryScreen extends StatefulWidget {
  const TreasuryScreen({super.key});

  @override
  State<TreasuryScreen> createState() => _TreasuryScreenState();
}

class _TreasuryScreenState extends State<TreasuryScreen> {
  late final TreasuryBloc _treasuryBloc;

  @override
  void initState() {
    super.initState();
    _treasuryBloc = InjectorContainer.getIt<TreasuryBloc>()
      ..add(FetchTreasuryMetricsEvent());
  }

  @override
  void dispose() {
    _treasuryBloc.close();
    super.dispose();
  }

  List<_Section> _sections(BuildContext context) {
    final router = context.router;
    return [
      _Section('Operación diaria', [
        _Module(
          title: 'Gestión Financiera',
          subtitle: 'Cajas, desembolsos y transacciones del día a día.',
          icon: Icons.account_balance_wallet_rounded,
          accent: _C.primary,
          onTap: () =>
              InjectorContainer.getIt<AppRouter>().push(HomeDashboardRoute()),
        ),
      ]),
      _Section('Préstamos', [
        _Module(
          title: 'Préstamos',
          subtitle: 'Préstamos que la empresa otorga a terceros.',
          icon: Icons.fact_check_rounded,
          accent: const Color(0xFF00B4D8),
          onTap: () => router.push(LoansHomeRoute()),
        ),
        _Module(
          title: 'Préstamos de Socios',
          subtitle: 'Préstamos que los socios ofrecen a la empresa.',
          icon: Icons.handshake_rounded,
          accent: _C.goldDeep,
          onTap: () => router.push(const MemberLoansHomeRoute()),
        ),
      ]),
      _Section('Capital y activos', [
        _Module(
          title: 'Aportes',
          subtitle: 'Aportaciones de capital de los socios.',
          icon: Icons.savings_rounded,
          accent: _C.green,
          onTap: () => router.push(ContributesHomeRoute()),
        ),
        _Module(
          title: 'Dividendos',
          subtitle: 'Distribución de utilidades a los socios.',
          icon: Icons.payments_rounded,
          accent: _C.purple,
          onTap: () => router.push(DistributeHomeRoute()),
        ),
        _Module(
          title: 'Inventario de Oro',
          subtitle: 'Control y valoración del oro físico.',
          icon: Icons.diamond_rounded,
          accent: const Color(0xFFD97706),
          onTap: () => router.push(GoldDashboardRoute()),
        ),
      ]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sections = _sections(context);

    return BlocProvider.value(
      value: _treasuryBloc,
      child: Scaffold(
        backgroundColor: _C.background,
        body: RefreshIndicator(
          color: _C.primary,
          onRefresh: () async => _treasuryBloc.add(FetchTreasuryMetricsEvent()),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  onRefresh: () =>
                      _treasuryBloc.add(FetchTreasuryMetricsEvent()),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const _SectionLabel('Resumen', helper: 'Estado de hoy'),
                    const SizedBox(height: 12),
                    const _MetricsRow(),
                    const SizedBox(height: 26),
                    for (final s in sections) ...[
                      _SectionLabel(s.label),
                      const SizedBox(height: 12),
                      for (final m in s.items) _ModuleCard(module: m),
                      const SizedBox(height: 22),
                    ],
                    _ReportCard(
                      onTap: () => context.router.push(FinancialReportsRoute()),
                    ),
                    const SizedBox(height: 14),
                    _LogoutButton(onTap: () => SessionActions.logout()),
                    const SizedBox(height: 28),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onRefresh;
  const _Header({required this.onRefresh});

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_C.primary, _C.primaryDeep],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
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
            top: 40,
            right: 50,
            child: _circle(70, _C.gold.withValues(alpha: 0.18)),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              GreetingUtil.getGreeting(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              UserSession.userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _GlassBtn(icon: Icons.refresh_rounded, onTap: onRefresh),
                      const SizedBox(width: 8),
                      _GlassBtn(
                        icon: Icons.logout_rounded,
                        onTap: () => SessionActions.logout(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.account_balance_rounded,
                                color: Colors.white, size: 13),
                            const SizedBox(width: 5),
                            Text(
                              'Tesorería · Hacienda',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.95),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Administra finanzas, préstamos y aportes desde aquí.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, color: Colors.white, size: 19),
      ),
    );
  }
}

// ─── Resumen (métricas) ──────────────────────────────────────────────────────

class _MetricsRow extends StatelessWidget {
  const _MetricsRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TreasuryBloc, TreasuryState>(
      builder: (context, state) {
        String pendientes = '—';
        String activos = '—';
        if (state is TreasuryMetricsLoaded) {
          pendientes = state.metrics.pendientes.toString();
          activos = state.metrics.activos.toString();
        }
        final loading = state is TreasuryMetricsLoading;

        return Row(
          children: [
            Expanded(
              child: _MetricTile(
                value: loading ? '…' : pendientes,
                title: 'Pendientes',
                helper: 'Esperan tu revisión y decisión',
                icon: Icons.assignment_late_rounded,
                color: _C.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricTile(
                value: loading ? '…' : activos,
                title: 'Activos',
                helper: 'Préstamos en curso ahora',
                icon: Icons.account_balance_wallet_rounded,
                color: _C.primary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String value;
  final String title;
  final String helper;
  final IconData icon;
  final Color color;
  const _MetricTile({
    required this.value,
    required this.title,
    required this.helper,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1B3E).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 17, color: color),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            helper,
            style: const TextStyle(
              fontSize: 11.5,
              height: 1.25,
              color: _C.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Secciones y tarjetas de módulo ──────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final String? helper;
  const _SectionLabel(this.text, {this.helper});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
          const Spacer(),
          Text(
            helper!,
            style: const TextStyle(
              fontSize: 11.5,
              color: _C.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final _Module module;
  const _ModuleCard({required this.module});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1B3E).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: module.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: module.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(module.icon, color: module.accent, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _C.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        module.subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.3,
                          color: _C.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: module.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward_ios_rounded,
                      color: module.accent, size: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Reporte y logout ────────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ReportCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1F2D4D), Color(0xFF0B1632)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.bar_chart_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reportes financieros',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Estado financiero y resúmenes mensuales.',
                    style: TextStyle(
                      color: Color(0xFFD1D5DB),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.logout_rounded,
            color: Color(0xFFE5484D), size: 18),
        label: const Text(
          'Cerrar sesión',
          style: TextStyle(
            color: Color(0xFFE5484D),
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: Color(0xFFFFD0D2), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
