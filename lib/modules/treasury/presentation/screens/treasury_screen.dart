import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/utils/session/session_actions.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

import '../bloc/treasury_bloc.dart';
import '../widgets/widgtes.dart';

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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: _treasuryBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                HeaderWidget(treasuryBloc: _treasuryBloc),
                Transform.translate(
                  offset: const Offset(0, -22),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocBuilder<TreasuryBloc, TreasuryState>(
                          builder: (context, state) {
                            if (state is TreasuryMetricsLoading) {
                              return const SizedBox(
                                height: 120,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (state is TreasuryMetricsError) {
                              return Container(
                                height: 120,
                                width: double.infinity,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  state.message,
                                  style: TextStyle(color: colors.red),
                                ),
                              );
                            }

                            if (state is TreasuryMetricsLoaded) {
                              final metrics = state.metrics;
                              return Row(
                                children: [
                                  Expanded(
                                    child: MetricCard(
                                      title: 'PENDIENTES',
                                      value: metrics.pendientes.toString(),
                                      subtitle:
                                          'Requieren revisión y\ndecisión inmediata',
                                      icon: Icons.assignment_late_outlined,
                                      color: const Color(0xFFF59E0B),
                                      decoColor: const Color(
                                        0xFFF59E0B,
                                      ).withValues(alpha: 0.10),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: MetricCard(
                                      title: 'ACTIVOS',
                                      value: metrics.activos.toString(),
                                      subtitle:
                                          'Préstamos en curso\nactualmente',
                                      icon:
                                          Icons.account_balance_wallet_outlined,
                                      color: const Color(0xFF2563FF),
                                      decoColor: const Color(
                                        0xFF2563FF,
                                      ).withValues(alpha: 0.08),
                                    ),
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(
                                  child: MetricCard(
                                    title: 'PENDIENTES',
                                    value: '0',
                                    subtitle:
                                        'Requieren revisión y\ndecisión inmediata',
                                    icon: Icons.assignment_late_outlined,
                                    color: const Color(0xFFF59E0B),
                                    decoColor: const Color(
                                      0xFFF59E0B,
                                    ).withValues(alpha: 0.10),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: MetricCard(
                                    title: 'ACTIVOS',
                                    value: '0',
                                    subtitle: 'Préstamos en curso\nactualmente',
                                    icon: Icons.account_balance_wallet_outlined,
                                    color: const Color(0xFF2563FF),
                                    decoColor: const Color(
                                      0xFF2563FF,
                                    ).withValues(alpha: 0.08),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Módulos Operativos',
                          style: AppTextStyles.mainStyle16Bold(context)
                              .copyWith(
                                fontSize: 18,
                                color: const Color(0xFF111827),
                              ),
                        ),
                        const SizedBox(height: 16),

                        _buildModuleCard(
                          context,
                          title: 'Gestion Financiera',
                          subtitle:
                              'Gestión Finaciera, Cajas,\nDesembolsos y transacciones.',
                          icon: Icons.account_balance_wallet_outlined,
                          iconColor: const Color(0xFF2563FF),
                          bgColor: const Color(0xFFEAF1FF),
                          onTap: () {
                            InjectorContainer.getIt<AppRouter>().push(
                              HomeDashboardRoute(),
                            );
                          },
                        ),
                        _buildModuleCard(
                          context,
                          title: 'Préstamos',
                          subtitle:
                              'Gestión de solicitudes, aprobación y\nseguimiento.',
                          icon: Icons.fact_check_outlined,
                          iconColor: const Color(0xFF2563FF),
                          bgColor: const Color(0xFFEAF1FF),
                          onTap: () {},
                        ),
                        _buildModuleCard(
                          context,
                          title: 'Dividendos',
                          subtitle:
                              'Distribución y registro de pagos a\naccionistas.',
                          icon: Icons.payments_outlined,
                          iconColor: const Color(0xFFA855F7),
                          bgColor: const Color(0xFFF3E8FF),
                          onTap: () {},
                        ),
                        _buildModuleCard(
                          context,
                          title: 'Inventario Oro',
                          subtitle: 'Control de activos físicos y valoración.',
                          icon: Icons.savings_outlined,
                          iconColor: const Color(0xFFD97706),
                          bgColor: const Color(0xFFFEF3C7),
                          onTap: () {},
                        ),
                        _buildModuleCard(
                          context,
                          title: 'Aportes',
                          subtitle:
                              'Registro de nuevas aportaciones de\ncapital.',
                          icon: Icons.login_outlined,
                          iconColor: const Color(0xFF0F9D8A),
                          bgColor: const Color(0xFFE7F8F5),
                          onTap: () {},
                        ),

                        const SizedBox(height: 22),
                        ReportButtonWidget(),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              SessionActions.logout();
                            },
                            icon: const Icon(
                              Icons.logout,
                              color: Color(0xFFFF4D4F),
                              size: 18,
                            ),
                            label: const Text(
                              'Cerrar Sesión',
                              style: TextStyle(
                                color: Color(0xFFFF4D4F),
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              side: const BorderSide(
                                color: Color(0xFFFFC9C9),
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF0F2F5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.mainStyle14Bold(context).copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: AppTextStyles.mainStyleGrey12(context).copyWith(
                      fontSize: 13,
                      height: 1.4,
                      color: const Color(0xFF667085),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
