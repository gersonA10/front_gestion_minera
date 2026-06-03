import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/payroll_monthly_entity.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../injector_container.dart';
import '../bloc/staff_bloc.dart';

import '../../../../utils/constants/color.constant.dart';

@RoutePage()
class ProcessPaymentScreen extends StatefulWidget {
  final PayrollMonthlyEntity payroll;
  final String payrollPeriod;
  const ProcessPaymentScreen({
    super.key,
    required this.payroll,
    required this.payrollPeriod,
  });

  @override
  State<ProcessPaymentScreen> createState() => _ProcessPaymentScreenState();
}

class _ProcessPaymentScreenState extends State<ProcessPaymentScreen> {
  final formatter = NumberFormat('#,##0.00', 'en_US');
  late final StaffBloc _bloc;
  final Uuid _uuid = const Uuid();
  String get imageUrl => '';
  PayrollMonthlyEntity get payroll => widget.payroll;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<StaffBloc>();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _listener(BuildContext context, StaffState state) {
    if (state is ProcessPayrollPaymentSuccess) {
      CustomAlert.show(
        context,
        title: 'Éxito',
        message: 'Pago procesado',
        type: AlertType.success,
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        context.router.pop(true);
      });
    }

    if (state is ProcessPayrollPaymentError) {
      CustomAlert.show(
        context,
        title: 'Error',
        message: state.message,
        type: AlertType.error,
      );
    }
  }

  Future<void> _showConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Pago'),
          content: Text(
            '¿Confirmar pago de '
            '${payroll.currency} ${formatter.format(payroll.netTotal)} '
            'a ${payroll.fullName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
    if (result != true) return;
    _bloc.add(
      ProcessPayrollPaymentEvent(
        payrollId: payroll.payrollId,
        idempotencyKey: _uuid.v4(),
      ),
    );
  }

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
      body: BlocConsumer<StaffBloc, StaffState>(
        bloc: _bloc,
        listener: _listener,
        builder: (context, state) {
          final isLoading = state is ProcessPayrollPaymentLoading;
          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
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
                                          backgroundImage: NetworkImage(
                                            imageUrl,
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 24,
                                          backgroundColor:
                                              TColors.avatarBackground,
                                          child: const Icon(
                                            Icons.person,
                                            color: TColors.avatarIconColor,
                                          ),
                                        ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          payroll.fullName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: TColors.appMainDarkColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          payroll.position,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: TColors.grayText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'ID: #${payroll.employeeId}',
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
                                  widget.payrollPeriod,
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
                                    '${payroll.currency} ${formatter.format(payroll.baseSalary)}',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${payroll.currency} ${formatter.format(payroll.netTotal)}',
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
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          payroll.currency,
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
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        HapticFeedback.lightImpact();
                                        await _showConfirmDialog();
                                      },
                                icon: isLoading
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
                                  isLoading
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
                                  disabledBackgroundColor:
                                      TColors.appDisabledColor,
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
          );
        },
      ),
    );
  }
}
