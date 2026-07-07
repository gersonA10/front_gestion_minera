import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';
import 'package:front_gestion_minera/modules/staff/presentation/screens/personnel_cash_screen.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/payroll_cycle_selector_widget.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/payroll_employee_card_widget.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/payroll_summary_card_widget.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

const List<String> _kMonths = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

@RoutePage()
class PayrollScreen extends StatefulWidget {
  final String? payrollPeriod;

  const PayrollScreen({super.key, this.payrollPeriod});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  late final StaffBloc _bloc;
  final TextEditingController searchController = TextEditingController();
  late String cycleLabel;
  late int selectedMonth;
  late int selectedYear;
  String selectedStatus = 'Todos';
  final List<String> statusFilters = ['Todos', 'Pagado', 'Pendiente'];
  double? _cajaBalance;

  bool get isHistoryMode => widget.payrollPeriod != null;

  int _getMonthFromPeriod(String period) {
    final name = period.split(' ').first;
    final idx = _kMonths.indexWhere(
        (m) => m.toLowerCase() == name.toLowerCase());
    return idx >= 0 ? idx + 1 : DateTime.now().month;
  }

  int _getYearFromPeriod(String period) =>
      int.tryParse(period.split(' ').last) ?? DateTime.now().year;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    if (isHistoryMode) {
      selectedMonth = _getMonthFromPeriod(widget.payrollPeriod!);
      selectedYear = _getYearFromPeriod(widget.payrollPeriod!);
      cycleLabel = widget.payrollPeriod!;
    } else {
      selectedMonth = now.month;
      selectedYear = now.year;
      cycleLabel = '${_kMonths[selectedMonth - 1]} $selectedYear';
    }

    _bloc = InjectorContainer.getIt<StaffBloc>();
    _bloc.add(
      GetPayrollMonthlyListEvent(month: selectedMonth, year: selectedYear),
    );
    if (!isHistoryMode) _bloc.add(GetCashBalanceEvent());
  }

  @override
  void dispose() {
    searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _reload() {
    _bloc.add(
      GetPayrollMonthlyListEvent(month: selectedMonth, year: selectedYear),
    );
  }

  Future<void> _openCycleSelector() async {
    final result = await PayrollCycleSelectorWidget.show(
      context,
      initialMonth: selectedMonth,
      initialYear: selectedYear,
    );
    if (result != null) {
      setState(() {
        selectedMonth = result.month;
        selectedYear = result.year;
        cycleLabel = result.displayText;
      });
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = BlocConsumer<StaffBloc, StaffState>(
      bloc: _bloc,
      listenWhen: (_, s) => s is CashBalanceLoaded,
      listener: (context, state) {
        if (state is CashBalanceLoaded) {
          setState(() => _cajaBalance = state.balance);
        }
      },
      buildWhen: (_, s) =>
          s is PayrollMonthlyLoading ||
          s is PayrollMonthlyLoaded ||
          s is PayrollMonthlyError,
      builder: (context, state) {
        if (state is PayrollMonthlyLoading) {
          return const StaffLoader();
        }
        if (state is PayrollMonthlyError) {
          return StaffErrorState(message: state.message, onRetry: _reload);
        }
        if (state is PayrollMonthlyLoaded) {
          return _buildLoaded(state);
        }
        return const SizedBox.shrink();
      },
    );

    if (isHistoryMode) {
      return Scaffold(
        backgroundColor: StaffUi.background,
        appBar: staffAppBar(context, title: cycleLabel),
        body: content,
      );
    }
    return content;
  }

  Widget _buildLoaded(PayrollMonthlyLoaded state) {
    final query = searchController.text.trim().toLowerCase();
    final filtered = state.payrolls.where((p) {
      final matchesSearch = query.isEmpty ||
          p.fullName.toLowerCase().contains(query) ||
          p.employeeId.toLowerCase().contains(query);
      final isPaid = p.paymentStatus.toUpperCase() == 'PAGADO';
      final matchesStatus = selectedStatus == 'Todos' ||
          (selectedStatus == 'Pagado' && isPaid) ||
          (selectedStatus == 'Pendiente' && !isPaid);
      return matchesSearch && matchesStatus;
    }).toList();

    return RefreshIndicator(
      color: StaffUi.primary,
      onRefresh: () async {
        _reload();
        if (!isHistoryMode) _bloc.add(GetCashBalanceEvent());
      },
      // Toda la pantalla scrollea (no solo la lista de empleados).
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                if (!isHistoryMode) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _CycleRow(
                      cycleLabel: cycleLabel,
                      onTapCycle: _openCycleSelector,
                      onTapHistory: () =>
                          context.router.push(StaffPaymentHistoryRoute()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _CajaCard(
                      balance: _cajaBalance,
                      onMovements: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PersonnelCashScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  height: 116,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      PayrollSummaryCardWidget(
                        icon: Icons.receipt_long_rounded,
                        title: 'Total nómina mes',
                        amount: StaffUi.money2(state.totalPayroll),
                        badge: 'MENSUAL',
                        iconColor: StaffUi.primary,
                        amountColor: StaffUi.textPrimary,
                      ),
                      PayrollSummaryCardWidget(
                        icon: Icons.check_circle_rounded,
                        title: 'Total pagado',
                        amount: StaffUi.money2(state.totalPaid),
                        iconColor: TColors.statusGreen,
                        amountColor: TColors.statusGreen,
                      ),
                      PayrollSummaryCardWidget(
                        icon: Icons.pending_actions_rounded,
                        title: 'Total pendiente',
                        amount: StaffUi.money2(state.totalPending),
                        iconColor: TColors.statusOrange,
                        amountColor: TColors.statusOrange,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: StaffSearchField(
                    controller: searchController,
                    hint: 'Buscar empleado o ID...',
                    onChanged: (_) => setState(() {}),
                    onClear: () => setState(() => searchController.clear()),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      for (final f in statusFilters) ...[
                        _FilterChip(
                          label: f,
                          active: selectedStatus == f,
                          onTap: () => setState(() => selectedStatus = f),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: StaffSectionTitle(
                    'Empleados',
                    trailing: '${filtered.length}',
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          if (filtered.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.04),
                child: const StaffEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Sin registros de nómina',
                  message:
                      'No hay empleados que coincidan con este ciclo o filtro.',
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              sliver: SliverList.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final payroll = filtered[index];
                  final isPaid =
                      payroll.paymentStatus.toUpperCase() == 'PAGADO';
                  return PayrollEmployeeCardWidget(
                    name: payroll.fullName,
                    position: payroll.position,
                    employeeId: payroll.employeeId,
                    amount: StaffUi.money2(payroll.netTotal),
                    paid: isPaid,
                    onTap: isPaid
                        ? null
                        : () async {
                            final result = await context.router.push<bool>(
                              ProcessPaymentRoute(
                                payroll: payroll,
                                payrollPeriod: cycleLabel,
                              ),
                            );
                            if (result == true) {
                              _reload();
                              _bloc.add(GetCashBalanceEvent());
                            }
                          },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Selector de ciclo + acceso al historial de pagos.
class _CycleRow extends StatelessWidget {
  final String cycleLabel;
  final VoidCallback onTapCycle;
  final VoidCallback onTapHistory;
  const _CycleRow({
    required this.cycleLabel,
    required this.onTapCycle,
    required this.onTapHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StaffCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            onTap: onTapCycle,
            child: Row(
              children: [
                const Icon(Icons.event_rounded,
                    size: 18, color: StaffUi.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ciclo de nómina',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: StaffUi.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        cycleLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: StaffUi.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 20, color: StaffUi.textSecondary),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onTapHistory,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: StaffUi.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: StaffUi.border),
              boxShadow: StaffUi.cardShadow,
            ),
            child: const Icon(Icons.history_rounded,
                size: 21, color: StaffUi.primary),
          ),
        ),
      ],
    );
  }
}

/// Tarjeta de saldo de la caja de personal (gradiente premium).
class _CajaCard extends StatelessWidget {
  final double? balance;
  final VoidCallback onMovements;
  const _CajaCard({required this.balance, required this.onMovements});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [StaffUi.primary, StaffUi.primaryDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: StaffUi.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.account_balance_wallet_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Caja de personal',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  balance == null ? '—' : StaffUi.money2(balance!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onMovements,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_rounded,
                      color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Movimientos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? StaffUi.primary : StaffUi.surface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: active ? StaffUi.primary : StaffUi.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : StaffUi.textSecondary,
          ),
        ),
      ),
    );
  }
}
