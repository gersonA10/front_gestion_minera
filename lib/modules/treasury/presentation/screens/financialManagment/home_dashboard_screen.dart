import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/screens/financialManagment/payment_history_screen.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';

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

String _money(double v) {
  final neg = v < 0;
  final s = v.abs().toStringAsFixed(2);
  final parts = s.split('.');
  final intPart = parts[0];
  final buf = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
    buf.write(intPart[i]);
  }
  return '${neg ? '-' : ''}Bs $buf.${parts[1]}';
}

@RoutePage()
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [const HomeBody(), PaymentHistoryScreen()];

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              InjectorContainer.getIt<TreasuryBloc>()..add(DashboardDataEvent()),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: _C.background,
            appBar: AppBar(
              backgroundColor: _C.background,
              surfaceTintColor: _C.background,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Gestión Financiera',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _C.textPrimary,
                ),
              ),
            ),
            body: IndexedStack(index: _selectedIndex, children: pages),
            floatingActionButton: _selectedIndex == 0
                ? FloatingActionButton.extended(
                    onPressed: () async {
                      await context.router.push(UrgentTransactionRoute());
                      if (context.mounted) {
                        context.read<TreasuryBloc>().add(DashboardDataEvent());
                      }
                    },
                    backgroundColor: _C.primary,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    icon: const Icon(Icons.bolt_rounded, color: Colors.white),
                    label: const Text(
                      'Transacción urgente',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  )
                : null,
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            bottomNavigationBar: NavigationBar(
              backgroundColor: Colors.white,
              elevation: 0,
              indicatorColor: const Color(0xFFE5EDFF),
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home_rounded,
                      color: _selectedIndex == 0 ? _C.primary : Colors.grey),
                  label: 'Inicio',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_rounded,
                      color: _selectedIndex == 1 ? _C.primary : Colors.grey),
                  label: 'Historial',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: RefreshIndicator(
        color: _C.primary,
        onRefresh: () async {
          context.read<TreasuryBloc>().add(DashboardDataEvent());
          await Future.delayed(const Duration(milliseconds: 600));
        },
        child: BlocConsumer<TreasuryBloc, TreasuryState>(
          listener: (context, state) {
            if (state is DashboardDataError) {
              CustomAlert.show(
                context,
                title: 'Error',
                message: state.message,
                type: AlertType.error,
              );
            }
          },
          builder: (context, state) {
            if (state is DashboardDataLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is! DashboardDataLoaded) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Text('Desliza para actualizar',
                        style: TextStyle(color: _C.textSecondary)),
                  ),
                ],
              );
            }

            final b = state.bondBalance;
            final pendientes = state.pendingApplicationsResponseEntity.data;
            final enCajas = b.cajaMayor + b.cajaChica;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
              children: [
                Text(
                  'Hola, ${UserSession.userName}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _C.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                _HeroEnCajas(
                  total: enCajas,
                  mayor: b.cajaMayor,
                  chica: b.cajaChica,
                ),
                const SizedBox(height: 16),
                _ReposicionesEntry(
                  onTap: () async {
                    await context.router.push(const ReconciliationsRoute());
                    if (context.mounted) {
                      context.read<TreasuryBloc>().add(DashboardDataEvent());
                    }
                  },
                ),
                const SizedBox(height: 24),
                const _SectionTitle('Situación financiera',
                    helper: 'Compromisos y posición'),
                const SizedBox(height: 12),
                _BalanceCard(
                  title: 'Disponible real',
                  amount: b.saldoDisponibleReal,
                  helper: b.saldoDisponibleReal < 0
                      ? 'En negativo: hay más compromisos que efectivo.'
                      : 'Tu posición neta tras todos los compromisos.',
                  icon: b.saldoDisponibleReal < 0
                      ? Icons.trending_down_rounded
                      : Icons.trending_up_rounded,
                  color: b.saldoDisponibleReal < 0
                      ? const Color(0xFFD32F2F)
                      : const Color(0xFF17A05D),
                  amountColor: b.saldoDisponibleReal < 0
                      ? const Color(0xFFD32F2F)
                      : null,
                  wide: true,
                ),
                const SizedBox(height: 12),
                _BalanceCard(
                  title: 'Por desembolsar',
                  amount: b.aDesembolsar,
                  helper: 'Reservado para pagos ya aprobados.',
                  icon: Icons.lock_clock_rounded,
                  color: const Color(0xFFC47A00),
                  wide: true,
                ),
                const SizedBox(height: 12),
                const _InfoNote(
                  text:
                      'El "disponible real" ya descuenta todos los compromisos, '
                      'por eso no es exactamente "en cajas" menos "por desembolsar".',
                ),
                const SizedBox(height: 24),
                _SectionTitle(
                  'Solicitudes pendientes',
                  helper: pendientes.isEmpty ? null : '${pendientes.length}',
                  onSeeAll: () =>
                      context.router.push(PendingApplicationsRoute()),
                ),
                const SizedBox(height: 12),
                if (pendientes.isEmpty)
                  const _PendingEmpty()
                else
                  ...pendientes.map(
                    (p) => _PendingTile(
                      motivo: p.motivo,
                      solicitante: p.solicitante,
                      monto: p.monto.toDouble(),
                      onTap: () async {
                        await InjectorContainer.getIt<AppRouter>()
                            .push(ViewRequestDetailsRoute(id: p.requestId));
                        if (context.mounted) {
                          context
                              .read<TreasuryBloc>()
                              .add(DashboardDataEvent());
                        }
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Acceso a reposiciones de campamento ─────────────────────────────────────

class _ReposicionesEntry extends StatelessWidget {
  final VoidCallback onTap;
  const _ReposicionesEntry({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFC47A00).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.sync_alt_rounded,
                color: Color(0xFFC47A00),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reposiciones de campamento',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _C.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Concilia devoluciones y compensaciones',
                    style: TextStyle(fontSize: 11.5, color: _C.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: _C.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero: saldo disponible real ─────────────────────────────────────────────

class _HeroEnCajas extends StatelessWidget {
  final double total;
  final double mayor;
  final double chica;
  const _HeroEnCajas({
    required this.total,
    required this.mayor,
    required this.chica,
  });

  Widget _circle(double s, Color c) => Container(
        width: s,
        height: s,
        decoration: BoxDecoration(shape: BoxShape.circle, color: c),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_C.primary, _C.primaryDeep],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _C.primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -24,
            child: _circle(120, Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            bottom: -40,
            left: -20,
            child: _circle(110, _C.gold.withValues(alpha: 0.10)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.account_balance_rounded,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Total en cajas',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _money(total),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Efectivo que hay en tus cajas',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _HeroPill(
                        label: 'Caja Mayor',
                        value: _money(mayor),
                        icon: Icons.account_balance_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _HeroPill(
                        label: 'Caja Chica',
                        value: _money(chica),
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _HeroPill(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.8)),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tarjeta de saldo ────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final String title;
  final double amount;
  final String helper;
  final IconData icon;
  final Color color;
  final bool wide;
  final Color? amountColor;
  const _BalanceCard({
    required this.title,
    required this.amount,
    required this.helper,
    required this.icon,
    required this.color,
    this.wide = false,
    this.amountColor,
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
      child: wide
          ? Row(
              children: [
                _iconBox(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _titleText(),
                      const SizedBox(height: 2),
                      _helperText(),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _amountText(),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _iconBox(),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 12),
                _amountText(),
                const SizedBox(height: 4),
                _titleText(),
                const SizedBox(height: 2),
                _helperText(),
              ],
            ),
    );
  }

  Widget _iconBox() => Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: color, size: 20),
      );

  Widget _amountText() => Text(
        _money(amount),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: amountColor ?? _C.textPrimary,
          letterSpacing: -0.3,
        ),
      );

  Widget _titleText() => Text(
        title,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: _C.textPrimary,
        ),
      );

  Widget _helperText() => Text(
        helper,
        style: const TextStyle(
          fontSize: 11,
          height: 1.25,
          color: _C.textSecondary,
        ),
      );
}

// ─── Sección + solicitudes ───────────────────────────────────────────────────

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

class _PendingTile extends StatelessWidget {
  final String motivo;
  final String solicitante;
  final double monto;
  final VoidCallback onTap;
  const _PendingTile({
    required this.motivo,
    required this.solicitante,
    required this.monto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC47A00).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.request_page_rounded,
                      color: Color(0xFFC47A00), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        motivo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Solicitante: $solicitante',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: _C.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _money(monto),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: _C.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 12, color: _C.textSecondary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  final String text;
  const _InfoNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _C.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: _C.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.35,
                color: _C.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingEmpty extends StatelessWidget {
  const _PendingEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
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
              color: const Color(0xFF17A05D).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                size: 32, color: Color(0xFF17A05D)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Todo al día',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'No hay solicitudes pendientes por revisar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: _C.textSecondary),
          ),
        ],
      ),
    );
  }
}
