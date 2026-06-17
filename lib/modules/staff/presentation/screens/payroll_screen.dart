import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/payroll_cycle_selector_widget.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/payroll_employee_card_widget.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/payroll_summary_card_widget.dart';
import 'package:front_gestion_minera/modules/staff/presentation/screens/personnel_cash_screen.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';

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
    const months = {
      'Enero': 1,
      'Febrero': 2,
      'Marzo': 3,
      'Abril': 4,
      'Mayo': 5,
      'Junio': 6,
      'Julio': 7,
      'Agosto': 8,
      'Septiembre': 9,
      'Octubre': 10,
      'Noviembre': 11,
      'Diciembre': 12,
    };
    final parts = period.split(' ');
    return months[parts[0]] ?? DateTime.now().month;
  }

  int _getYearFromPeriod(String period) {
    final parts = period.split(' ');
    return int.tryParse(parts.last) ?? DateTime.now().year;
  }

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
      const meses = [
        'Enero',
        'Febrero',
        'Marzo',
        'Abril',
        'Mayo',
        'Junio',
        'Julio',
        'Agosto',
        'Septiembre',
        'Octubre',
        'Noviembre',
        'Diciembre',
      ];
      cycleLabel = '${meses[selectedMonth - 1]} $selectedYear';
    }
    _bloc = InjectorContainer.getIt<StaffBloc>();
    _bloc.add(
      GetPayrollMonthlyListEvent(month: selectedMonth, year: selectedYear),
    );
    _bloc.add(GetCashBalanceEvent());
  }

  @override
  void dispose() {
    searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.textFieldBackgroundColor,
      appBar: AppBar(
        backgroundColor: TColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isHistoryMode ? 'Historial de Pagos' : 'Gestionar Nómina',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: TColors.appMainDarkColor,
                  ),
                ),
              ),
              if (!isHistoryMode)
                GestureDetector(
                  onTap: () {
                    context.router.push(StaffPaymentHistoryRoute());
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history,
                        size: 16,
                        color: TColors.appMainColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Historial de pagos',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: TColors.appMainColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      body: BlocConsumer<StaffBloc, StaffState>(
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
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PayrollMonthlyError) {
            return Center(child: Text(state.message));
          }
          if (state is PayrollMonthlyLoaded) {
            final payrolls = state.payrolls;
            final filteredPayrolls = payrolls.where((payroll) {
              final query = searchController.text.trim().toLowerCase();
              final matchesSearch =
                  query.isEmpty ||
                  payroll.fullName.toLowerCase().contains(query) ||
                  payroll.employeeId.toLowerCase().contains(query);
              final isPaid = payroll.paymentStatus.toUpperCase() == 'PAGADO';
              final matchesStatus =
                  selectedStatus == 'Todos' ||
                  (selectedStatus == 'Pagado' && isPaid) ||
                  (selectedStatus == 'Pendiente' && !isPaid);
              return matchesSearch && matchesStatus;
            }).toList();
            return SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  _bloc.add(
                    GetPayrollMonthlyListEvent(
                      month: selectedMonth,
                      year: selectedYear,
                    ),
                  );
                },
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: isHistoryMode
                          ? null
                          : () async {
                              final result =
                                  await PayrollCycleSelectorWidget.show(
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
                                _bloc.add(
                                  GetPayrollMonthlyListEvent(
                                    month: selectedMonth,
                                    year: selectedYear,
                                  ),
                                );
                              }
                            },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Ciclo:  ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: TColors.appDisabledColor,
                                ),
                              ),
                              Text(
                                cycleLabel,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: TColors.appMainColor,
                                ),
                              ),
                              const SizedBox(width: 2),
                              if (!isHistoryMode)
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: TColors.appMainColor,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: TColors.appMainColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.account_balance_wallet,
                                color: TColors.white, size: 26),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Caja de Personal',
                                      style: TextStyle(
                                          color: TColors.white, fontSize: 12)),
                                  Text(
                                    _cajaBalance == null
                                        ? '...'
                                        : '${_cajaBalance!.toStringAsFixed(2)} Bs',
                                    style: const TextStyle(
                                        color: TColors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PersonnelCashScreen(),
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: TColors.white,
                              ),
                              icon: const Icon(Icons.receipt_long, size: 16),
                              label: const Text('Movimientos'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 130,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        children: [
                          PayrollSummaryCardWidget(
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'Total Nómina Mes',
                            amount: state.totalPayroll.toStringAsFixed(2),
                            badge: 'MENSUAL',
                            iconColor: TColors.appMainColor,
                            amountColor: TColors.appMainTextColor,
                          ),
                          const SizedBox(width: 5),
                          PayrollSummaryCardWidget(
                            icon: Icons.check_circle_outline,
                            title: 'Total Pagado',
                            amount: state.totalPaid.toStringAsFixed(2),
                            iconColor: TColors.green,
                            amountColor: TColors.green,
                            showBottomIndicator: true,
                          ),
                          const SizedBox(width: 5),
                          PayrollSummaryCardWidget(
                            icon: Icons.pending_actions_outlined,
                            title: 'Total Pendiente',
                            amount: state.totalPending.toStringAsFixed(2),
                            iconColor: TColors.amber,
                            amountColor: TColors.amber,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Buscar empleado o ID...',
                                hintStyle: TextStyle(
                                  color: TColors.appDisabledColor,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: const Icon(Icons.search),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              setState(() {
                                selectedStatus = value;
                              });
                            },
                            itemBuilder: (context) => statusFilters
                                .map(
                                  (item) => PopupMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: TColors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.tune,
                                color: TColors.appMainDarkColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text(
                            selectedStatus.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: TColors.appMainColor,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'LISTA DE EMPLEADOS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: TColors.appDisabledColor,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Total: ${filteredPayrolls.length}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: TColors.appMainColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: filteredPayrolls.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 200),
                                Center(
                                  child: Text('No se encontraron registros'),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: filteredPayrolls.length,
                              itemBuilder: (context, index) {
                                final payroll = filteredPayrolls[index];
                                return PayrollEmployeeCardWidget(
                                  name: payroll.fullName,
                                  position: payroll.position,
                                  employeeId: payroll.employeeId,
                                  amount: payroll.netTotal.toStringAsFixed(2),
                                  paid:
                                      payroll.paymentStatus.toUpperCase() ==
                                      'PAGADO',
                                  onTap: () async {
                                    final isPaid =
                                        payroll.paymentStatus.toUpperCase() ==
                                        'PAGADO';
                                    if (isPaid) {
                                      return;
                                    }
                                    final result = await context.router
                                        .push<bool>(
                                          ProcessPaymentRoute(
                                            payroll: payroll,
                                            payrollPeriod: cycleLabel,
                                          ),
                                        );

                                    if (result == true) {
                                      _bloc.add(
                                        GetPayrollMonthlyListEvent(
                                          month: selectedMonth,
                                          year: selectedYear,
                                        ),
                                      );
                                      _bloc.add(GetCashBalanceEvent());
                                    }
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
