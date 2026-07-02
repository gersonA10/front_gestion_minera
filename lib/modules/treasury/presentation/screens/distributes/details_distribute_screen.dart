import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';
import '../../../domain/entity/entity.dart';
import '../../widgets/widgtes.dart';

@RoutePage()
class DividendDistributionDetailsScreen extends StatefulWidget {
  final String distributionId;

  const DividendDistributionDetailsScreen({
    super.key,
    required this.distributionId,
  });

  @override
  State<DividendDistributionDetailsScreen> createState() =>
      _DividendDistributionDetailsScreenState();
}

class _DividendDistributionDetailsScreenState
    extends State<DividendDistributionDetailsScreen> {
  String _filtro = 'Todos';
  late final TreasuryBloc _bloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<TreasuryBloc>()
      ..add(
        GetDistributionDetailEvent(
          distributionId: widget.distributionId,
          isRefresh: true,
        ),
      )
      ..add(GetCashRegistersEvent());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _bloc.add(LoadMoreDistributionDetailEvent());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _esPendiente(DistributionDetailMemberEntity m) =>
      m.status.toLowerCase() == 'pendiente';

  List<DistributionDetailMemberEntity> _applyFilter(
    List<DistributionDetailMemberEntity> members,
  ) {
    if (_filtro == 'Todos') return members;
    if (_filtro == 'Pendientes') return members.where(_esPendiente).toList();
    return members.where((m) => !_esPendiente(m)).toList();
  }

  String _formatCurrency(double value) => NumberFormat.currency(
    locale: 'es_BO',
    symbol: 'Bs',
    decimalDigits: 2,
  ).format(value);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: TColors.background,
        appBar: AppBar(
          backgroundColor: TColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: TColors.textPrimary,
              size: 18,
            ),
            onPressed: () => context.router.back(),
          ),
          title: const Text(
            'Detalle del Dividendo',
            style: TextStyle(
              color: TColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ),
        body: BlocBuilder<TreasuryBloc, TreasuryState>(
          buildWhen: (_, curr) =>
              curr is DistributionDetailLoading ||
              curr is DistributionDetailLoaded ||
              curr is DistributionDetailError,
          builder: (context, state) {
            if (state is DistributionDetailLoading) {
              return const Center(child: StaffLoader(),);
            }

            if (state is DistributionDetailError) {
              context.router.back();
              CustomAlert.show(
                context,
                title: 'Error',
                message: state.message,
                type: AlertType.error,
              );
            }
            if (state is DistributionDetailLoaded) {
              final header = state.header;
              final filtered = _applyFilter(state.membersList);

              return RefreshIndicator(
                color: TColors.primary,
                onRefresh: () async {
                  _bloc.add(
                    GetDistributionDetailEvent(
                      distributionId: widget.distributionId,
                      isRefresh: true,
                    ),
                  );
                  await _bloc.stream.firstWhere(
                    (s) =>
                        s is DistributionDetailLoaded ||
                        s is DistributionDetailError,
                  );
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeaderCard(
                        header: header,
                        formatCurrency: _formatCurrency,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: SummaryCardDistributes(
                              label: 'Total Pagado',
                              value: _formatCurrency(header.totalPaidAmount),
                              valueColor: TColors.success,
                              bgColor: TColors.successLight,
                              icon: Icons.check_circle_outline_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SummaryCardDistributes(
                              label: 'Saldo Pendiente',
                              value: _formatCurrency(header.totalPendingAmount),
                              valueColor: TColors.warning,
                              bgColor: TColors.warningLight,
                              icon: Icons.schedule_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: TColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: TColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CounterItem(
                              value: '${header.totalMembers}',
                              label: 'TOTAL',
                              color: TColors.textPrimary,
                            ),
                            Container(
                              width: 1,
                              height: 36,
                              color: TColors.border,
                            ),
                            CounterItem(
                              value: '${header.paidMembers}',
                              label: 'PAGADOS',
                              color: TColors.success,
                            ),
                            Container(
                              width: 1,
                              height: 36,
                              color: TColors.border,
                            ),
                            CounterItem(
                              value: '${header.pendingMembers}',
                              label: 'PENDIENTES',
                              color: TColors.warning,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Text(
                            'Socios',
                            style: TextStyle(
                              color: TColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: TColors.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${filtered.length}',
                              style: const TextStyle(
                                color: TColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: ['Todos', 'Pendientes', 'Pagados'].map((f) {
                          final selected = _filtro == f;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _filtro = f),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? TColors.textPrimary
                                      : TColors.surface,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: selected
                                        ? TColors.textPrimary
                                        : TColors.border,
                                  ),
                                ),
                                child: Text(
                                  f,
                                  style: TextStyle(
                                    color: selected
                                        ? TColors.white
                                        : TColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 48, bottom: 24),
                          child: Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: TColors.primaryLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.people_outline_rounded,
                                    color: TColors.primary,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'Sin socios en este filtro',
                                  style: TextStyle(
                                    color: TColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Prueba seleccionando otro estado',
                                  style: TextStyle(
                                    color: TColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...filtered.map(
                          (member) => MemberCard(
                            member: member,
                            formatCurrency: _formatCurrency,
                            distributionId: widget.distributionId,
                            distributionPeriod: header.period,
                          ),
                        ),

                      if (!state.hasReachedMax)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: TColors.primary,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
