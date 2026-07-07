import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:intl/intl.dart';
import '../../widgets/widgtes.dart';
import 'contributes_ui.dart';

@RoutePage()
class ContributesDetailScreen extends StatefulWidget {
  final String contributionId;
  final DateTime dateContibution;
  final String titleContibuton;
  const ContributesDetailScreen({
    super.key,
    required this.contributionId,
    required this.dateContibution,
    required this.titleContibuton,
  });

  @override
  State<ContributesDetailScreen> createState() =>
      _ContributesDetailScreenState();
}

class _ContributesDetailScreenState extends State<ContributesDetailScreen> {
  int _selectedTab = 0;
  late final TreasuryBloc _bloc;
  final _fmt = NumberFormat('#,##0.##', 'es_PE');

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<TreasuryBloc>()
      ..add(GetContributionDetailEvent(contributionId: widget.contributionId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) context.router.back();
        },
        child: Scaffold(
          backgroundColor: CUi.bg,
          appBar: contribAppBar(
            context,
            title: 'Detalle de Aporte',
            actions: [
              IconButton(
                tooltip: 'Historial de recibos',
                icon: const Icon(Icons.history_rounded, color: CUi.textPrimary),
                onPressed: () => context.router.push(
                  ReceiptsHistoryRoute(contributionId: widget.contributionId),
                ),
              ),
            ],
          ),
          body: BlocBuilder<TreasuryBloc, TreasuryState>(
            buildWhen: (_, state) =>
                state is ContributionDetailLoading ||
                state is ContributionDetailLoaded ||
                state is ContributionDetailError,
            builder: (context, state) {
              if (state is ContributionDetailLoading) {
                return const StaffLoader();
              }
              if (state is ContributionDetailError) {
                return CStateView(
                  icon: Icons.cloud_off_rounded,
                  color: CUi.danger,
                  title: 'No pudimos cargar el detalle',
                  subtitle: state.message,
                );
              }
              if (state is ContributionDetailLoaded) {
                final pendientes = state.membersList
                    .where((m) => m.status.toLowerCase() == 'pendiente')
                    .toList();
                final pagados = state.membersList
                    .where((m) => m.status.toLowerCase() != 'pendiente')
                    .toList();
                final lista = _selectedTab == 0 ? pendientes : pagados;
                final cash = state.cash;
                final h = state.headerMetrics;
                final progress = h.totalGoal <= 0
                    ? 0.0
                    : (h.actualCollected / h.totalGoal).clamp(0.0, 1.0);

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _hero(h.reason, h.totalGoal, h.actualCollected,
                          h.pendingAmount, progress),
                      const SizedBox(height: 20),
                      // Tabs
                      Container(
                        decoration: BoxDecoration(
                          color: CUi.fieldBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            TabBtnContribute(
                              label: 'Pendientes',
                              count: pendientes.length,
                              active: _selectedTab == 0,
                              onTap: () => setState(() => _selectedTab = 0),
                            ),
                            TabBtnContribute(
                              label: 'Pagados',
                              count: pagados.length,
                              active: _selectedTab == 1,
                              onTap: () => setState(() => _selectedTab = 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (lista.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: CStateView(
                            icon: _selectedTab == 0
                                ? Icons.task_alt_rounded
                                : Icons.people_outline_rounded,
                            color: CUi.primary,
                            title: _selectedTab == 0
                                ? 'Sin pendientes'
                                : 'Sin pagos registrados',
                            subtitle: _selectedTab == 0
                                ? 'Todos los socios están al día.'
                                : 'Aún no hay socios que hayan pagado.',
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: lista.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => SocioCard(
                            item: lista[i],
                            isPendiente: _selectedTab == 0,
                            dateContibution: widget.dateContibution,
                            titleContibuton: widget.titleContibuton,
                            cash: cash,
                          ),
                        ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  // Hero con degradado: motivo, meta total, progreso y recaudado/pendiente.
  Widget _hero(
    String reason,
    double goal,
    double collected,
    double pending,
    double progress,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: CUi.gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CUi.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reason,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'META TOTAL',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_fmt.format(goal)} Bs',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso de recaudación',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _heroMini('Recaudado', collected)),
              Container(
                width: 1,
                height: 38,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white.withValues(alpha: 0.18),
              ),
              Expanded(child: _heroMini('Pendiente', pending)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroMini(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_fmt.format(value)} Bs',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
