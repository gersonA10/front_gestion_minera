import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class PersonnelCashScreen extends StatefulWidget {
  const PersonnelCashScreen({super.key});

  @override
  State<PersonnelCashScreen> createState() => _PersonnelCashScreenState();
}

class _PersonnelCashScreenState extends State<PersonnelCashScreen> {
  late final StaffBloc _bloc;
  String? _payingId;

  static const _months = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<StaffBloc>()..add(GetPersonnelCashEvent());
  }

  String _monthLabel(int m) => (m >= 1 && m <= 12) ? _months[m - 1] : '$m';

  void _confirmPay(CashPayableEntity p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar pago'),
        content: Text(
          'Pagar a ${p.fullName} la nómina de ${_monthLabel(p.month)} ${p.year} '
          'por ${StaffUi.money2(p.net)} desde la Caja de Personal?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _payingId = p.payrollId);
              _bloc.add(PayPayrollFromCashEvent(p.payrollId));
            },
            child: const Text('Pagar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: StaffUi.background,
        appBar: staffAppBar(context, title: 'Caja de personal'),
        body: BlocConsumer<StaffBloc, StaffState>(
          listenWhen: (_, s) => s is PayPayrollSuccess || s is PayPayrollError,
          listener: (ctx, state) {
            if (state is PayPayrollSuccess) {
              setState(() => _payingId = null);
              CustomAlert.show(ctx,
                  title: 'Listo',
                  message: state.message,
                  type: AlertType.success);
            } else if (state is PayPayrollError) {
              setState(() => _payingId = null);
              CustomAlert.show(ctx,
                  title: 'Error',
                  message: state.message,
                  type: AlertType.error);
            }
          },
          buildWhen: (_, s) =>
              s is PersonnelCashLoading ||
              s is PersonnelCashLoaded ||
              s is PersonnelCashError,
          builder: (context, state) {
            if (state is PersonnelCashLoading) {
              return const StaffLoader();
            }
            if (state is PersonnelCashError) {
              return StaffErrorState(
                message: state.message,
                onRetry: () => _bloc.add(GetPersonnelCashEvent()),
              );
            }
            if (state is PersonnelCashLoaded) {
              return RefreshIndicator(
                color: StaffUi.primary,
                onRefresh: () async => _bloc.add(GetPersonnelCashEvent()),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  children: [
                    _BalanceCard(balance: state.balance),
                    const SizedBox(height: 22),
                    StaffSectionTitle(
                      'Pendientes por pagar',
                      icon: Icons.pending_actions_rounded,
                      trailing: '${state.payables.length}',
                    ),
                    const SizedBox(height: 12),
                    if (state.payables.isEmpty)
                      const StaffEmptyState(
                        icon: Icons.task_alt_rounded,
                        title: 'Todo al día',
                        message: 'No hay nóminas pendientes por pagar.',
                      )
                    else
                      ...state.payables.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PayableCard(
                            payable: p,
                            balance: state.balance,
                            isPaying: _payingId == p.payrollId,
                            locked: _payingId != null,
                            monthLabel: _monthLabel(p.month),
                            onPay: () => _confirmPay(p),
                          ),
                        ),
                      ),
                    const SizedBox(height: 22),
                    StaffSectionTitle(
                      'Movimientos',
                      icon: Icons.swap_vert_rounded,
                      trailing: '${state.movements.length}',
                    ),
                    const SizedBox(height: 12),
                    if (state.movements.isEmpty)
                      const StaffEmptyState(
                        icon: Icons.receipt_long_rounded,
                        title: 'Sin movimientos',
                        message: 'Aún no se registran movimientos en la caja.',
                      )
                    else
                      ...state.movements.map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _MovementCard(movement: m),
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
    );
  }
}

/// Tarjeta de saldo disponible con gradiente premium (réplica del estilo
/// `_CajaCard` de la pantalla de Nómina).
class _BalanceCard extends StatelessWidget {
  final double balance;
  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [StaffUi.primary, StaffUi.primaryDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: StaffUi.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 23),
              ),
              const SizedBox(width: 12),
              Text(
                'SALDO DISPONIBLE',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            StaffUi.money2(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Disponible para pago de nóminas',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Item de nómina pendiente: datos del empleado + botón compacto Pagar/Sin saldo.
class _PayableCard extends StatelessWidget {
  final CashPayableEntity payable;
  final double balance;
  final bool isPaying;
  final bool locked;
  final String monthLabel;
  final VoidCallback onPay;

  const _PayableCard({
    required this.payable,
    required this.balance,
    required this.isPaying,
    required this.locked,
    required this.monthLabel,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final canPay = balance >= payable.net;

    return StaffCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  payable.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: StaffUi.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (payable.isOverdue)
                const StaffPill(
                  label: 'Atrasado',
                  color: Color(0xFFEF4444),
                  bg: Color(0xFFFEF2F2),
                  icon: Icons.schedule_rounded,
                )
              else
                StaffPill.status('PENDIENTE',
                    icon: Icons.access_time_rounded),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.event_rounded,
                  size: 14, color: StaffUi.textSecondary),
              const SizedBox(width: 5),
              Text(
                '$monthLabel ${payable.year}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: StaffUi.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monto neto',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: StaffUi.muted,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      StaffUi.money2(payable.net),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: StaffUi.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _PayButton(
                canPay: canPay,
                isPaying: isPaying,
                onPay: (canPay && !locked) ? onPay : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Botón compacto coherente con el botón primario del módulo.
class _PayButton extends StatelessWidget {
  final bool canPay;
  final bool isPaying;
  final VoidCallback? onPay;

  const _PayButton({
    required this.canPay,
    required this.isPaying,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: isPaying ? null : onPay,
        style: ElevatedButton.styleFrom(
          backgroundColor: StaffUi.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: canPay
              ? StaffUi.primary.withValues(alpha: 0.5)
              : StaffUi.muted.withValues(alpha: 0.4),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: isPaying
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    canPay ? Icons.payments_rounded : Icons.block_rounded,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(canPay ? 'Pagar' : 'Sin saldo'),
                ],
              ),
      ),
    );
  }
}

/// Item de movimiento de caja: icono entrada/salida + monto en verde/naranja.
class _MovementCard extends StatelessWidget {
  final CashMovementEntity movement;
  const _MovementCard({required this.movement});

  @override
  Widget build(BuildContext context) {
    final isIncome = movement.isIncome;
    final color = isIncome ? TColors.statusGreen : TColors.statusOrange;
    final bg = isIncome ? TColors.statusGreenBg : TColors.statusOrangeBg;

    return StaffCard(
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome
                  ? Icons.south_west_rounded
                  : Icons.north_east_rounded,
              color: color,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: StaffUi.textPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 12, color: StaffUi.muted),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        movement.createdAt,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: StaffUi.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${isIncome ? '+' : '-'}${StaffUi.money2(movement.amount, symbol: false)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
