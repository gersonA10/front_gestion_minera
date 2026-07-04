import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/utils/date_util.dart';
import 'package:intl/intl.dart';
import '../../../domain/entity/entity.dart';
import '../../widgets/widgtes.dart';
import 'loan_ui.dart';

@RoutePage()
class LoanSimulationScreen extends StatefulWidget {
  final NewLoansResponseEntity loan;
  final CashResponseEntity cash;
  final String name;
  final String date;
  final double annualInterestRate;
  const LoanSimulationScreen({
    super.key,
    required this.loan,
    required this.cash,
    required this.name,
    required this.date,
    required this.annualInterestRate,
  });

  @override
  State<LoanSimulationScreen> createState() => _LoanSimulationScreenState();
}

class _LoanSimulationScreenState extends State<LoanSimulationScreen> {
  String? selectedSourceId;
  late TreasuryBloc treasuryBloc;
  final _fmt = NumberFormat('#,##0.##', 'es_PE');

  @override
  void initState() {
    super.initState();
    treasuryBloc = InjectorContainer.getIt<TreasuryBloc>();
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.loan.summary;
    return BlocProvider.value(
      value: treasuryBloc,
      child: Scaffold(
        backgroundColor: LoanUi.bg,
        appBar: loanAppBar(context, title: 'Simulación de Préstamo'),
        body: BlocConsumer<TreasuryBloc, TreasuryState>(
          listenWhen: (_, state) =>
              state is ApplyForALoanLoaded || state is ApplyForALoanError,
          listener: (context, state) {
            if (state is ApplyForALoanLoaded) {
              // Avisamos (lo hostea el ScaffoldMessenger raíz, sobrevive al pop)
              // y volvemos directo al home, no solo a "Nuevo Préstamo".
              CustomAlert.show(
                context,
                title: 'Éxito',
                message: 'Préstamo registrado exitosamente',
                type: AlertType.success,
              );
              context.router.popUntilRouteWithName(LoansHomeRoute.name);
            } else if (state is ApplyForALoanError) {
              CustomAlert.show(
                context,
                title: 'Error',
                message: state.message,
                type: AlertType.error,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is ApplyForALoanLoading;
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LoanSummaryCard(
                              loan: widget.loan,
                              rate: widget.annualInterestRate,
                            ),
                            const SizedBox(height: 24),
                            LoanSectionTitle(
                              'Cronograma de Pagos',
                              icon: Icons.event_note_rounded,
                              trailing:
                                  '${widget.loan.cronograma.length} cuotas',
                            ),
                            const SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.loan.cronograma.length,
                              itemBuilder: (context, index) {
                                final installment =
                                    widget.loan.cronograma[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5.0,
                                  ),
                                  child: PaymentInstallmentCard(
                                    number: installment.installmentNumber,
                                    dueDate: formatDate(installment.dueDate),
                                    amount: installment.totalInstallment,
                                    capital: installment.principal,
                                    interest: installment.interest,
                                    status: installment.status,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                      decoration: const BoxDecoration(
                        color: LoanUi.surface,
                        border: Border(top: BorderSide(color: LoanUi.border)),
                      ),
                      child: LoanPrimaryButton(
                        label: 'Confirmar',
                        icon: Icons.check_rounded,
                        onPressed: () => _openConfirmDialog(context, summary),
                      ),
                    ),
                  ],
                ),
                if (isLoading)
                  const StaffSubmitOverlay(label: 'Procesando'),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openConfirmDialog(BuildContext context, SummaryEntity summary) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: LoanUi.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: LoanUi.primarySoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: LoanUi.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Confirmar Solicitud',
                                style: TextStyle(
                                  color: LoanUi.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Revisa los detalles antes de confirmar',
                                style: TextStyle(
                                  color: LoanUi.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: LoanUi.border, height: 1),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: LoanUi.bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: LoanUi.border),
                      ),
                      child: Column(
                        children: [
                          _dialogRow(
                            'Monto solicitado',
                            _fmt.format(summary.amount),
                            valueColor: LoanUi.textPrimary,
                          ),
                          const SizedBox(height: 10),
                          _dialogRow(
                            'Cuota mensual',
                            _fmt.format(summary.monthlyInstallment),
                            valueColor: LoanUi.textSecondary,
                          ),
                          const SizedBox(height: 10),
                          const Divider(color: LoanUi.border, height: 1),
                          const SizedBox(height: 10),
                          _dialogRow(
                            'Total General',
                            _fmt.format(summary.totalPayable),
                            valueColor: LoanUi.finalizado,
                            bold: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Caja de destino',
                      style: TextStyle(
                        color: LoanUi.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: widget.cash.data.map((res) {
                        final isSelected = selectedSourceId == res.id;
                        return Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  selectedSourceId = res.id;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? LoanUi.primarySoft
                                      : LoanUi.bg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? LoanUi.primary
                                        : LoanUi.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      res.nombre.contains('Chica')
                                          ? Icons.money_outlined
                                          : Icons.account_balance_outlined,
                                      color: isSelected
                                          ? LoanUi.primary
                                          : LoanUi.muted,
                                      size: 22,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      res.nombre,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isSelected
                                            ? LoanUi.primary
                                            : LoanUi.textSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: LoanUi.textSecondary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: LoanUi.border),
                              ),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (selectedSourceId == null) {
                                CustomAlert.show(
                                  context,
                                  title: 'Error',
                                  message:
                                      'Por favor selecciona una caja de destino',
                                  type: AlertType.error,
                                );
                                return;
                              }
                              treasuryBloc.add(
                                ApplyForALoanEvent(
                                  lenderName: widget.name,
                                  amount: widget.loan.summary.amount,
                                  termMonths: widget.loan.summary.termMonths,
                                  annualInterestRate: widget.annualInterestRate,
                                  startDate: formatDateISO(DateTime.now()),
                                  cajaDestinoId: selectedSourceId!,
                                ),
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LoanUi.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  LoanUi.primary.withValues(alpha: 0.3),
                              disabledForegroundColor: Colors.white54,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Confirmar',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _dialogRow(
    String label,
    String value, {
    required Color valueColor,
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: bold ? LoanUi.textPrimary : LoanUi.textSecondary,
            fontSize: bold ? 13 : 12,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: bold ? 14 : 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
