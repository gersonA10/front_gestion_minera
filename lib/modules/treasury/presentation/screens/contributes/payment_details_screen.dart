import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

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
      child: Scaffold(
        backgroundColor: TColors.appBackgroundColor,
        appBar: AppBar(
          backgroundColor: TColors.lightContainerAccount,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Confirmación',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: TColors.appMainTextColor,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<TreasuryBloc, TreasuryState>(
          builder: (context, state) {
            if (state is ContributionPaymentReceiptLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ContributionPaymentReceiptError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
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
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: TColors.green.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle_outline_rounded,
                              color: TColors.green,
                              size: 42,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '¡Pago Exitoso!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: TColors.appMainTextColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            receipt.receiptStatus,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: TColors.appSecondaryTextColor,
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
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            if (widget.screen) {
                              context.router.back();
                              context.router.back();
                            } else {
                              context.router.back();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: TColors.appSurfaceColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Volver al Detalle',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: TColors.appMainTextColor,
                            ),
                          ),
                        ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: TColors.green,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'TOTAL PAGADO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: TColors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Bs ${amountPaid.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: TColors.white,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: TColors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'ID: ${transactionId.substring(0, 8).toUpperCase()}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: TColors.white,
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: TColors.lightContainerAccount,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.appSurfaceColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SOCIO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: TColors.appSecondaryTextColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      paidBy,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: TColors.appMainTextColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: TColors.appSurfaceColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 20,
                    color: TColors.appSecondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          // Divisor punteado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DashedDivider(),
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
            style: const TextStyle(
              fontSize: 13,
              color: TColors.appSecondaryTextColor,
            ),
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
              fontWeight: FontWeight.w600,
              color: TColors.appMainTextColor,
            ),
          ),
        ),
      ],
    );
  }
}

class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          children: List.generate(count, (_) {
            return Container(
              width: dashWidth,
              height: 1,
              margin: const EdgeInsets.only(right: dashSpace),
              color: TColors.appSurfaceColor,
            );
          }),
        );
      },
    );
  }
}
