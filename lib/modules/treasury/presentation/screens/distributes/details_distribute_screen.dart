import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
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
      ..add(GetDistributionDetailEvent(
        distributionId: widget.distributionId,
        isRefresh: true,
      ));
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
      List<DistributionDetailMemberEntity> members) {
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
            icon: const Icon(Icons.arrow_back_ios,
                color: TColors.textPrimary, size: 18),
            onPressed: () => context.router.back(),
          ),
          title: const Text(
            'Detalle de Distribución\nde Dividendos',
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
              return const Center(child: ExcavatorLoader());
            }

            if (state is DistributionDetailError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: TColors.danger, size: 48),
                    const SizedBox(height: 12),
                    Text(state.message,
                        style: const TextStyle(
                            color: TColors.textSecondary, fontSize: 13),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _bloc.add(GetDistributionDetailEvent(
                        distributionId: widget.distributionId,
                        isRefresh: true,
                      )),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: TColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is DistributionDetailLoaded) {
              final header = state.header;
              final filtered = _applyFilter(state.membersList);

              return RefreshIndicator(
                color: TColors.primary,
                onRefresh: () async {
                  _bloc.add(GetDistributionDetailEvent(
                    distributionId: widget.distributionId,
                    isRefresh: true,
                  ));
                  await _bloc.stream.firstWhere((s) =>
                      s is DistributionDetailLoaded ||
                      s is DistributionDetailError);
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderCard(
                          header: header, formatCurrency: _formatCurrency),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: SummaryCardDistributes(
                              label: 'Monto Registrado',
                              value: _formatCurrency(
                                  header.totalRegisteredAmount),
                              valueColor: TColors.textPrimary,
                              bgColor: TColors.primaryLight,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SummaryCardDistributes(
                              label: 'Saldo Pendiente',
                              value: _formatCurrency(
                                  header.totalPendingAmount),
                              valueColor: TColors.warning,
                              bgColor: TColors.warningLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SummaryCardDistributes(
                        label: 'Total Pagado',
                        value: _formatCurrency(header.totalPaidAmount),
                        valueColor: TColors.success,
                        bgColor: TColors.successLight,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 14),

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
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
                                color: TColors.border),
                            CounterItem(
                              value: '${header.paidMembers}',
                              label: 'PAGADOS',
                              color: TColors.success,
                            ),
                            Container(
                                width: 1,
                                height: 36,
                                color: TColors.border),
                            CounterItem(
                              value: '${header.pendingMembers}',
                              label: 'PENDIENTES',
                              color: TColors.warning,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children:
                            ['Todos', 'Pendientes', 'Pagados'].map((f) {
                          final selected = _filtro == f;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _filtro = f),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 9),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? TColors.textPrimary
                                      : TColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(30),
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
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(
                            child: Text('Sin registros',
                                style: TextStyle(
                                    color: TColors.textSecondary,
                                    fontSize: 13)),
                          ),
                        )
                      else
                        ...filtered.map((member) => _MemberCard(
                              member: member,
                              formatCurrency: _formatCurrency,
                            )),

                      if (!state.hasReachedMax)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: TColors.primary)),
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

// ─── Header card ─────────────────────────────────────────────────────────────
class _HeaderCard extends StatelessWidget {
  final DistributionDetailHeaderEntity header;
  final String Function(double) formatCurrency;

  const _HeaderCard({required this.header, required this.formatCurrency});

  bool get _isAbierto => header.status.toLowerCase() == 'abierto';
  Color get _statusColor =>
      _isAbierto ? const Color(0xFF0EA5E9) : TColors.success;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isAbierto
              ? [const Color(0xFF0C2340), const Color(0xFF1A4060)]
              : [const Color(0xFF1A2A1A), const Color(0xFF2D4A2D)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                header.period,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${header.totalMembers} socios',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: _statusColor.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                      color: _statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(
                  header.status,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Member card ─────────────────────────────────────────────────────────────
class _MemberCard extends StatelessWidget {
  final DistributionDetailMemberEntity member;
  final String Function(double) formatCurrency;

  const _MemberCard({required this.member, required this.formatCurrency});

  bool get _isPendiente => member.status.toLowerCase() == 'pendiente';
  Color get _statusColor => _isPendiente ? TColors.warning : TColors.success;
  Color get _avatarBg =>
      _isPendiente ? TColors.warningLight : TColors.successLight;

  String get _initials {
    final parts = member.fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return member.fullName.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.border),
        boxShadow: [
          BoxShadow(
            color: TColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration:
                    BoxDecoration(color: _avatarBg, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    _initials,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName,
                      style: const TextStyle(
                        color: TColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (member.paymentDate != null)
                      Text(
                        'Pagado: ${member.paymentDate}',
                        style: const TextStyle(
                            color: TColors.textSecondary, fontSize: 11),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: TColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _statusColor),
                ),
                child: Text(
                  member.status,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: TColors.border),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MONTO ASIGNADO',
                    style: TextStyle(
                      color: TColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatCurrency(member.assignedAmount),
                    style: const TextStyle(
                      color: TColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (_isPendiente)
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: TColors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Pagar',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                )
              else
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.receipt_long_outlined,
                      color: TColors.textSecondary, size: 15),
                  label: const Text(
                    'Ver recibo',
                    style: TextStyle(
                      color: TColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
