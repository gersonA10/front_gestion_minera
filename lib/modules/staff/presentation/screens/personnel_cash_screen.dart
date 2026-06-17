import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';
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
          'por ${p.net.toStringAsFixed(2)} Bs desde la Caja de Personal?',
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
        backgroundColor: TColors.appBackgroundColor,
        appBar: AppBar(
          backgroundColor: TColors.white,
          centerTitle: true,
          title: const Text('Caja de Personal'),
        ),
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
              return const Center(child: CircularProgressIndicator());
            }
            if (state is PersonnelCashError) {
              return _ErrorState(
                message: state.message,
                onRetry: () => _bloc.add(GetPersonnelCashEvent()),
              );
            }
            if (state is PersonnelCashLoaded) {
              return RefreshIndicator(
                onRefresh: () async => _bloc.add(GetPersonnelCashEvent()),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    _balanceCard(state.balance),
                    const SizedBox(height: 20),
                    _sectionTitle('Pendientes por pagar', state.payables.length),
                    const SizedBox(height: 8),
                    if (state.payables.isEmpty)
                      _emptyHint('No hay nóminas pendientes por pagar.')
                    else
                      ...state.payables.map((p) => _payableCard(p, state.balance)),
                    const SizedBox(height: 20),
                    _sectionTitle('Movimientos', state.movements.length),
                    const SizedBox(height: 8),
                    if (state.movements.isEmpty)
                      _emptyHint('Sin movimientos todavía.')
                    else
                      ...state.movements.map(_movementTile),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _balanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: TColors.appMainColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SALDO DISPONIBLE',
              style: TextStyle(
                  color: TColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
          const SizedBox(height: 6),
          Text('${balance.toStringAsFixed(2)} Bs',
              style: const TextStyle(
                  color: TColors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, int count) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: TColors.appMainDarkColor)),
        const SizedBox(width: 6),
        Text('($count)',
            style: const TextStyle(
                fontSize: 13, color: TColors.profileMutedLabel)),
      ],
    );
  }

  Widget _emptyHint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(text,
          style: const TextStyle(color: TColors.profileMutedLabel)),
    );
  }

  Widget _payableCard(CashPayableEntity p, double balance) {
    final canPay = balance >= p.net;
    final isPaying = _payingId == p.payrollId;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(p.fullName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                    if (p.isOverdue) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: TColors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Atrasado',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: TColors.red)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text('${_monthLabel(p.month)} ${p.year} · ${p.net.toStringAsFixed(2)} Bs',
                    style: const TextStyle(
                        fontSize: 12, color: TColors.profileMutedLabel)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: (canPay && _payingId == null) ? () => _confirmPay(p) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.appMainColor,
                foregroundColor: TColors.white,
                disabledBackgroundColor: TColors.disabled,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: isPaying
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: TColors.white))
                  : Text(canPay ? 'Pagar' : 'Sin saldo'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _movementTile(CashMovementEntity m) {
    final isIncome = m.isIncome;
    final color = isIncome ? TColors.success : TColors.red;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(m.createdAt,
                    style: const TextStyle(
                        fontSize: 11, color: TColors.profileMutedLabel)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('${isIncome ? '+' : '-'}${m.amount.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 44, color: TColors.disabled),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
