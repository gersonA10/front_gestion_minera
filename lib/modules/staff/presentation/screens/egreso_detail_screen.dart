import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/egreso_detail_entity.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class EgresoDetailScreen extends StatefulWidget {
  final String requestId;
  final String cycle;

  const EgresoDetailScreen({
    super.key,
    required this.requestId,
    required this.cycle,
  });

  @override
  State<EgresoDetailScreen> createState() => _EgresoDetailScreenState();
}

class _EgresoDetailScreenState extends State<EgresoDetailScreen> {
  late final StaffBloc _bloc;

  static const _months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<StaffBloc>()
      ..add(GetEgresoDetailEvent(widget.requestId));
  }

  String _monthLabel(int m) =>
      (m >= 1 && m <= 12) ? _months[m - 1] : '$m';

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: TColors.white,
        appBar: AppBar(
          title: Column(
            children: [
              const Text('Detalle del Egreso', style: TextStyle(fontSize: 16)),
              Text(widget.cycle, style: const TextStyle(fontSize: 12)),
            ],
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<StaffBloc, StaffState>(
          buildWhen: (_, s) =>
              s is EgresoDetailLoading ||
              s is EgresoDetailLoaded ||
              s is EgresoDetailError,
          builder: (context, state) {
            if (state is EgresoDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is EgresoDetailError) {
              return _ErrorState(
                message: state.message,
                onRetry: () => _bloc.add(GetEgresoDetailEvent(widget.requestId)),
              );
            }
            if (state is EgresoDetailLoaded) {
              if (state.items.isEmpty) {
                return const Center(
                  child: Text('Este egreso no tiene trabajadores asociados.'),
                );
              }
              final total = state.items.fold<double>(
                0,
                (s, e) => s + e.netTotal,
              );
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  _summary(state.items.length, total),
                  const SizedBox(height: 16),
                  ...state.items.map(_workerCard),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _summary(int count, double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TColors.appBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TOTAL DEL EGRESO',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: TColors.appMainDarkColor)),
          const SizedBox(height: 4),
          Text('${total.toStringAsFixed(2)} Bs',
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Trabajadores'),
              const Spacer(),
              Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _workerCard(EgresoDetailItemEntity e) {
    final isPaid = e.paymentStatus.toUpperCase() == 'PAGADO';
    final hasBackBalance = e.mesesPendientes > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.fullName,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    if (e.position.isNotEmpty)
                      Text(e.position,
                          style: const TextStyle(
                              fontSize: 12, color: TColors.profileMutedLabel)),
                  ],
                ),
              ),
              _StatusBadge(isPaid: isPaid),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.event_rounded,
                  size: 14, color: TColors.profileMutedLabel),
              const SizedBox(width: 5),
              Text('${_monthLabel(e.month)} ${e.year}',
                  style: const TextStyle(
                      fontSize: 13, color: TColors.profileBodyText)),
              const Spacer(),
              Text('${e.netTotal.toStringAsFixed(2)} Bs',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800)),
            ],
          ),
          if (isPaid && e.paymentDate != null) ...[
            const SizedBox(height: 4),
            Text('Pagado el ${e.paymentDate}',
                style: const TextStyle(
                    fontSize: 11, color: TColors.profileMutedLabel)),
          ],
          if (e.totalPendiente > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: (hasBackBalance ? TColors.red : TColors.amber)
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    hasBackBalance
                        ? Icons.warning_amber_rounded
                        : Icons.info_outline_rounded,
                    size: 16,
                    color: hasBackBalance ? TColors.red : TColors.amber,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Saldo pendiente: ${e.totalPendiente.toStringAsFixed(2)} Bs '
                      '(${e.mesesPendientes} ${e.mesesPendientes == 1 ? "mes" : "meses"})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: hasBackBalance ? TColors.red : TColors.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isPaid;
  const _StatusBadge({required this.isPaid});

  @override
  Widget build(BuildContext context) {
    final color = isPaid ? TColors.green : TColors.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPaid ? 'Pagado' : 'Pendiente',
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: color),
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
