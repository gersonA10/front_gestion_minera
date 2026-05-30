import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants/color.constant.dart';

@RoutePage()
class ProcessPaymentScreen extends StatefulWidget {
  const ProcessPaymentScreen({super.key});

  @override
  State<ProcessPaymentScreen> createState() => _ProcessPaymentScreenState();
}

class _ProcessPaymentScreenState extends State<ProcessPaymentScreen> {
  bool isProcessingPayment = false;
  final String employeeId = '29481';
  final String fullName = 'Juan Pérez';
  final String position = 'Operador Excavadora';
  final double baseSalary = 2500;
  final double totalDeductions = 0;
  final double netTotal = 2500;
  final String paymentStatus = 'PENDIENTE';
  final String currency = 'Bs';
  final String imageUrl = '';
  final String payrollPeriod = 'Octubre 2026';
  final String payrollId = '...';
  final formatter = NumberFormat('#,##0.00', 'en_US');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: TColors.white,
        surfaceTintColor: TColors.white,
        centerTitle: true,
        title: const Text(
          'Procesar Pago',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: TColors.appMainDarkColor,
          ),
        ),
        leading: IconButton(
          onPressed: () => context.router.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: TColors.appMainDarkColor,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: TColors.textFieldBackgroundColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: TColors.border),
                          ),
                          child: Row(
                            children: [
                              imageUrl.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 24,
                                      backgroundImage: NetworkImage(imageUrl),
                                    )
                                  : CircleAvatar(
                                      radius: 24,
                                      backgroundColor: TColors.avatarBackground,
                                      child: const Icon(
                                        Icons.person,
                                        color: TColors.avatarIconColor,
                                      ),
                                    ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fullName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: TColors.appMainDarkColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      position,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: TColors.grayText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'ID: #$employeeId',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: TColors.appDisabledColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'PERIODO DE PAGO',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1,
                            color: TColors.grayText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              payrollPeriod,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: TColors.profileBlue,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: TColors.textFieldBackgroundColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: TColors.border),
                              ),
                              child: const Text(
                                'Nómina Mensual',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: const [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 15,
                              color: TColors.grayText,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Percepciones',
                              style: TextStyle(
                                color: TColors.grayText,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: TColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: TColors.border),
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Salario Base',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              Text(
                                '$currency ${formatter.format(baseSalary)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: TColors.textFieldBackgroundColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: TColors.textFieldFocusedBorderColor,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Neto a Pagar',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: TColors.grayText,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '$currency ${formatter.format(netTotal)}',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                        color: TColors.appMainDarkColor,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: TColors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      currency,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: TColors.profileBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: isProcessingPayment
                                ? null
                                : () async {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      isProcessingPayment = true;
                                    });
                                    await Future.delayed(
                                      const Duration(seconds: 2),
                                    );
                                    if (!mounted) return;
                                    setState(() {
                                      isProcessingPayment = false;
                                    });
                                  },
                            icon: isProcessingPayment
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: TColors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.check_circle_outline,
                                    size: 20,
                                  ),
                            label: Text(
                              isProcessingPayment
                                  ? 'Procesando Pago...'
                                  : 'Confirmar y Pagar',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: TColors.amber,
                              foregroundColor: TColors.white,
                              disabledBackgroundColor: TColors.appDisabledColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Al confirmar, el pago será procesado y se enviará automáticamente un comprobante digital al correo electrónico del trabajador.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.5,
                              color: TColors.grayText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
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
