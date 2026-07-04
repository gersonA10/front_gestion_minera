import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:intl/intl.dart';
import 'contributes_ui.dart';

@RoutePage()
class PaymentConfirmationScreen extends StatefulWidget {
  final String transactionId;
  final bool screen;
  const PaymentConfirmationScreen({
    super.key,
    required this.transactionId,
    required this.screen,
  });

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  late TreasuryBloc _treasuryBloc;

  @override
  void initState() {
    super.initState();
    _treasuryBloc = InjectorContainer.getIt<TreasuryBloc>();
    _treasuryBloc.add(
      GetContributionPaymentReceiptEvent(transactionId: widget.transactionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _treasuryBloc,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) context.router.back();
        },
        child: Scaffold(
          backgroundColor: CUi.bg,
          appBar: contribAppBar(
            context,
            title: 'Comprobante de pago',
            showBack: false,
          ),
          body: BlocBuilder<TreasuryBloc, TreasuryState>(
            builder: (context, state) {
              if (state is ContributionPaymentReceiptLoading) {
                return const StaffLoader();
              }
              if (state is ContributionPaymentReceiptError) {
                return CStateView(
                  icon: Icons.cloud_off_rounded,
                  color: CUi.danger,
                  title: 'No pudimos cargar el comprobante',
                  subtitle: state.message,
                );
              }
              if (state is ContributionPaymentReceiptLoaded) {
                final receipt = state.receipt;
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: CUi.success.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle_outline_rounded,
                                color: CUi.success,
                                size: 44,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '¡Pago Exitoso!',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: CUi.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              receipt.receiptStatus,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: CUi.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            TotalPagadoCard(
                              amountPaid: receipt.amountPaid,
                              transactionId: receipt.transactionId,
                            ),
                            const SizedBox(height: 16),
                            DetalleCard(
                              paidBy: receipt.paidBy,
                              reason: receipt.reason,
                              period: receipt.period,
                              paymentDate: receipt.paymentDate,
                              registeredBy: receipt.registeredBy,
                              observation: receipt.observation,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: COutlinedButton(
                                label: 'Volver al detalle',
                                onPressed: () => context.router.back(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CPrimaryButton(
                                label: 'Ir al inicio',
                                icon: Icons.home_rounded,
                                onPressed: () => CUi.goHome(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class TotalPagadoCard extends StatelessWidget {
  final double amountPaid;
  final String transactionId;

  const TotalPagadoCard({
    super.key,
    required this.amountPaid,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'es_PE');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: CUi.success,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: CUi.success.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'TOTAL PAGADO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Bs ${fmt.format(amountPaid)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'ID: ${transactionId.length >= 8 ? transactionId.substring(0, 8).toUpperCase() : transactionId.toUpperCase()}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetalleCard extends StatelessWidget {
  final String paidBy;
  final String reason;
  final String period;
  final DateTime paymentDate;
  final String registeredBy;
  final String observation;

  const DetalleCard({
    super.key,
    required this.paidBy,
    required this.reason,
    required this.period,
    required this.paymentDate,
    required this.registeredBy,
    required this.observation,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${paymentDate.day.toString().padLeft(2, '0')}/${paymentDate.month.toString().padLeft(2, '0')}/${paymentDate.year}';
    final formattedTime =
        '${paymentDate.hour.toString().padLeft(2, '0')}:${paymentDate.minute.toString().padLeft(2, '0')}';

    return CCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SOCIO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: CUi.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        paidBy,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: CUi.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: CUi.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 20,
                    color: CUi.primary,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: CUi.border, height: 1),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              children: [
                DetalleRow(label: 'Concepto', value: reason),
                const SizedBox(height: 12),
                DetalleRow(label: 'Periodo', value: period),
                const SizedBox(height: 12),
                DetalleRow(label: 'Fecha Pago', value: formattedDate),
                const SizedBox(height: 12),
                DetalleRow(label: 'Hora', value: formattedTime),
                const SizedBox(height: 12),
                DetalleRow(label: 'Observación', value: observation),
                const SizedBox(height: 12),
                DetalleRow(label: 'Registrado por', value: registeredBy),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetalleRow extends StatelessWidget {
  final String label;
  final String value;

  const DetalleRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: CUi.textSecondary),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: CUi.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
