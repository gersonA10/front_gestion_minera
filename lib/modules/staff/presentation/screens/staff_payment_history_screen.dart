import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/payroll_history_entity.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';

@RoutePage()
class StaffPaymentHistoryScreen extends StatefulWidget {
  const StaffPaymentHistoryScreen({super.key});

  @override
  State<StaffPaymentHistoryScreen> createState() =>
      _StaffPaymentHistoryScreenState();
}

class _StaffPaymentHistoryScreenState extends State<StaffPaymentHistoryScreen> {
  late final StaffBloc _bloc;
  late int selectedYear;
  List<int> years = [];

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<StaffBloc>();
    selectedYear = DateTime.now().year;
    years = List.generate(5, (index) => DateTime.now().year - index);
    _bloc.add(GetPayrollHistoryEvent(year: selectedYear));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _fetchHistory({required int year}) {
    _bloc.add(GetPayrollHistoryEvent(year: year));
  }

  void _openPeriod(String period) {
    context.router.push(PayrollRoute(payrollPeriod: period));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StaffUi.background,
      appBar: staffAppBar(context, title: 'Historial de pagos'),
      body: Column(
        children: [
          _YearSelector(
            years: years,
            selectedYear: selectedYear,
            onSelected: (year) {
              setState(() => selectedYear = year);
              _fetchHistory(year: year);
            },
          ),
          Expanded(
            child: BlocBuilder<StaffBloc, StaffState>(
              bloc: _bloc,
              builder: (context, state) {
                if (state is PayrollHistoryLoading) {
                  return const StaffLoader();
                }
                if (state is PayrollHistoryError) {
                  return StaffErrorState(
                    message: state.message,
                    onRetry: () => _fetchHistory(year: selectedYear),
                  );
                }
                if (state is PayrollHistoryLoaded) {
                  return _buildLoaded(state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoaded(PayrollHistoryLoaded state) {
    final latest = state.history.latestPayment;
    final previous = state.history.previousCycles;
    final hasLatest = latest.period.isNotEmpty;

    return RefreshIndicator(
      color: StaffUi.primary,
      onRefresh: () async => _fetchHistory(year: selectedYear),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          if (!hasLatest && previous.isEmpty)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: StaffEmptyState(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Sin historial de pagos',
                message:
                    'No existen pagos registrados para el año $selectedYear.',
              ),
            )
          else ...[
            if (hasLatest) ...[
              const StaffSectionTitle(
                'Último pago',
                icon: Icons.bolt_rounded,
              ),
              const SizedBox(height: 12),
              _LatestPaymentCard(
                payment: latest,
                onDetail: () => _openPeriod(latest.period),
              ),
              const SizedBox(height: 24),
            ],
            StaffSectionTitle(
              'Ciclos anteriores',
              icon: Icons.history_rounded,
              trailing: previous.isEmpty ? null : '${previous.length}',
            ),
            const SizedBox(height: 12),
            if (previous.isEmpty)
              StaffCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: StaffUi.primarySoft,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.history_rounded,
                        color: StaffUi.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Sin ciclos anteriores',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: StaffUi.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Solo existe un pago registrado para el año $selectedYear.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: StaffUi.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...previous.map(
                (payroll) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PreviousCycleCard(
                    payroll: payroll,
                    onTap: () => _openPeriod(payroll.period),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Selector de año estilo segmented chips (mismo lenguaje que payroll_screen).
class _YearSelector extends StatelessWidget {
  final List<int> years;
  final int selectedYear;
  final ValueChanged<int> onSelected;
  const _YearSelector({
    required this.years,
    required this.selectedYear,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: StaffUi.surface,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: years.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final year = years[index];
            final active = selectedYear == year;
            return GestureDetector(
              onTap: () => onSelected(year),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? StaffUi.primary : StaffUi.surface,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: active ? StaffUi.primary : StaffUi.border,
                  ),
                ),
                child: Text(
                  year.toString(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : StaffUi.textSecondary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Tarjeta destacada del último pago (gradiente premium, como _CajaCard).
class _LatestPaymentCard extends StatelessWidget {
  final PayrollHistoryEntity payment;
  final VoidCallback onDetail;
  const _LatestPaymentCard({required this.payment, required this.onDetail});

  @override
  Widget build(BuildContext context) {
    final style = StaffStatusStyle.of(payment.status);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  payment.period,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      style.label,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            StaffUi.money2(payment.totalAmount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Text(
                'Pagado el ${payment.paymentDate}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: StaffUi.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.receipt_long_rounded, size: 18),
              label: const Text(
                'Ver detalle de nómina',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de un ciclo anterior (superficie clara, tokens del kit).
class _PreviousCycleCard extends StatelessWidget {
  final PayrollHistoryEntity payroll;
  final VoidCallback onTap;
  const _PreviousCycleCard({required this.payroll, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return StaffCard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: StaffUi.primarySoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 19,
                  color: StaffUi.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payroll.period,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: StaffUi.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (payroll.payrollType.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        payroll.payrollType,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: StaffUi.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              StaffPill.status(payroll.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monto total',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: StaffUi.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      StaffUi.money2(payroll.totalAmount),
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: StaffUi.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Fecha de pago',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: StaffUi.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    payroll.paymentDate,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: StaffUi.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                'Ver detalle',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: StaffUi.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: StaffUi.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
