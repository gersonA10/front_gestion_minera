import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/previous_cycle_card_widget.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class StaffPaymentHistoryScreen extends StatefulWidget {
  const StaffPaymentHistoryScreen({super.key});

  @override
  State<StaffPaymentHistoryScreen> createState() =>
      _StaffPaymentHistoryScreenState();
}

class _StaffPaymentHistoryScreenState extends State<StaffPaymentHistoryScreen> {
  late final StaffBloc _bloc;
  final ScrollController _scrollController = ScrollController();
  late int selectedYear;
  List<int> years = [];

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<StaffBloc>();
    selectedYear = DateTime.now().year;
    years = List.generate(5, (index) => DateTime.now().year - index);
    _bloc.add(GetPayrollHistoryEvent(year: selectedYear));
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {}
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _fetchHistory({required int year}) {
    _bloc.add(GetPayrollHistoryEvent(year: year));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.textFieldBackgroundColor,
      appBar: AppBar(
        backgroundColor: TColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Historial de Pagos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: TColors.appMainDarkColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.filter_list,
              color: TColors.appMainDarkColor,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: TColors.white,
            height: 48,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: years.length,
              itemBuilder: (context, index) {
                final year = years[index];
                final selected = selectedYear == year;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedYear = year;
                    });
                    _fetchHistory(year: year);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 24),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: selected
                              ? TColors.appMainColor
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      year.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? TColors.appMainColor
                            : TColors.appDisabledColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<StaffBloc, StaffState>(
              bloc: _bloc,
              builder: (context, state) {
                if (state is PayrollHistoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is PayrollHistoryError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 50,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 12),
                          Text(state.message, textAlign: TextAlign.center),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              _fetchHistory(year: selectedYear);
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (state is PayrollHistoryLoaded) {
                  final latest = state.history.latestPayment;
                  final previous = state.history.previousCycles;
                  if (latest.period.isEmpty && previous.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        _fetchHistory(year: selectedYear);
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.65,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 110,
                                      height: 110,
                                      decoration: BoxDecoration(
                                        color: TColors.primaryLight,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          const Icon(
                                            Icons
                                                .account_balance_wallet_outlined,
                                            size: 56,
                                            color: TColors.appMainDarkColor,
                                          ),

                                          Positioned(
                                            top: 18,
                                            right: 18,
                                            child: Container(
                                              width: 28,
                                              height: 28,
                                              decoration: const BoxDecoration(
                                                color: TColors.appMainColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 16,
                                                color: TColors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    const Text(
                                      'Sin Historial de Pagos',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: TColors.appMainDarkColor,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Text(
                                      'No existen pagos registrados para el año $selectedYear.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: TColors.appDisabledColor,
                                        height: 1.5,
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    SizedBox(
                                      width: 180,
                                      height: 44,
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          _fetchHistory(year: selectedYear);
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: TColors.appMainColor,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.refresh,
                                          color: TColors.appMainColor,
                                        ),
                                        label: const Text(
                                          'Actualizar',
                                          style: TextStyle(
                                            color: TColors.appMainColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      _fetchHistory(year: selectedYear);
                    },
                    child: ListView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      children: [
                        const Text(
                          'ÚLTIMO PAGO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: TColors.appDisabledColor,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: TColors.appMainColor,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [
                              BoxShadow(
                                color: TColors.appMainColor,
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      latest.period,
                                      style: const TextStyle(
                                        color: TColors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: TColors.white.withAlpha(50),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: TColors.white,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          latest.status,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: TColors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '\$${latest.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: TColors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Pagado el ${latest.paymentDate}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: TColors.white,
                                    foregroundColor: TColors.appMainColor,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(Icons.receipt_long_outlined),
                                  label: const Text(
                                    'Ver Detalle de Nómina',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'CICLOS ANTERIORES',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: TColors.appDisabledColor,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: previous.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final payroll = previous[index];
                            return PreviousCycleCardWidget(
                              period: payroll.period,
                              payrollType: payroll.payrollType,
                              totalAmount: payroll.totalAmount,
                              paymentDate: payroll.paymentDate,
                              status: payroll.status,
                              onTap: () {},
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
