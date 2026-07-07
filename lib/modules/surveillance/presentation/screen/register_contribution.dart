import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/modules/surveillance/domain/entity/contribution_entity.dart';
import 'package:front_gestion_minera/modules/surveillance/presentation/bloc/surveillance_bloc.dart';
import 'package:front_gestion_minera/modules/surveillance/presentation/widget/amunt_input_field.dart';
import 'package:front_gestion_minera/modules/surveillance/presentation/widget/calculation_preview_widget.dart';
import 'package:front_gestion_minera/modules/surveillance/presentation/widget/success_receipt_dialog_widget.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

class RegisterContributionsView extends StatefulWidget {
  const RegisterContributionsView({super.key});

  @override
  State<RegisterContributionsView> createState() => _RegisterContributionsViewState();
}

class _RegisterContributionsViewState extends State<RegisterContributionsView> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _onCalculatePressed() {
    final amountText = _amountController.text.trim();
    final reasonText = _reasonController.text.trim();
    final double? amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      CustomAlert.show(
        context,
        title: 'Monto Inválido',
        message: 'Por favor, ingrese un monto válido.',
        type: AlertType.error,
      );
      return;
    }

     if (reasonText.isEmpty) {
      CustomAlert.show(
        context,
        title: 'Motivo Inválido',
        message: 'Por favor, ingrese un motivo válido.',
        type: AlertType.error,
      );
      return;
    }

    FocusScope.of(context).unfocus();
    
    context.read<SurveillanceBloc>().add(
      CalculateContributionEvent(montoTotal: amount),
    );
  }

  void _showCalculationPreview(ContributionCalculationEntity calculation) {
    // Capturamos el bloc y el motivo actual para pasarlo al BottomSheet
    final bloc = context.read<SurveillanceBloc>();
    final motivo = _reasonController.text.trim();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: bloc, // Proveemos el bloc al modal
        child: CalculationPreviewSheet(
          calculation: calculation,
          motivo: motivo,
          onSuccess: (registration) {
            Navigator.pop(sheetContext); // Cierra el modal
            _amountController.clear();
            _reasonController.clear();
            _showSuccessReceipt(registration); // Muestra el éxito
          },
        ),
      ),
    );
  }

  void _showSuccessReceipt(ContributionRegistrationEntity registration) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SuccessReceiptDialog(
        registration: registration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final smallSpacing = screenSize.height * 0.02;

    return BlocConsumer<SurveillanceBloc, SurveillanceState>(
      listener: (context, state) {
        if (state is SurveillanceCalculateSuccess) {
          _showCalculationPreview(state.calculation);
        } else if (state is SurveillanceCalculateError) {
          CustomAlert.show(
            context,
            title: 'Error de Cálculo',
            message: state.message,
            type: AlertType.error,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is SurveillanceCalculateLoading;

        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Registro de Aporte",
                  style: AppTextStyles.mainStyle16Bold(context).copyWith(fontSize: 20),
                ),
                SizedBox(height: smallSpacing * 0.5),
                Text(
                  "Ingrese el monto que será procesado para el cálculo de aportes por persona.",
                  style: AppTextStyles.mainStyle12(context).copyWith(color: colors.lead),
                ),
                
                SizedBox(height: smallSpacing * 1.5),
                
                // CAMPO: MONTO
                Text(
                  "Monto Total (Bs.)",
                  style: AppTextStyles.mainStyle12Bold(context).copyWith(color: colors.black.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 8),
                AmountInputField(controller: _amountController, colors: colors),
                
                SizedBox(height: smallSpacing * 1.5),
                
                // CAMPO: MOTIVO (NUEVO)
                Text(
                  "Motivo / Descripción (Opcional)",
                  style: AppTextStyles.mainStyle12Bold(context).copyWith(color: colors.black.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.lead.withValues(alpha: 0.3)),
                  ),
                  child: TextField(
                    controller: _reasonController,
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                    style: AppTextStyles.mainStyle14(context).copyWith(color: colors.black),
                    decoration: InputDecoration(
                      hintText: 'Ej. Compra de repuestos para excavadora',
                      hintStyle: AppTextStyles.mainStyle14(context).copyWith(color: colors.lead.withValues(alpha: 0.5)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
          
                const Spacer(),
          
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _onCalculatePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: colors.white, strokeWidth: 3))
                        : Text(
                            'Calcular',
                            style: AppTextStyles.mainStyle14Bold(context).copyWith(color: colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}