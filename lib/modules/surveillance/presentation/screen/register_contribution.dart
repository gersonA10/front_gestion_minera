import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/modules/surveillance/presentation/widget/amunt_input_field.dart';
import 'package:front_gestion_minera/modules/surveillance/presentation/widget/calculation_preview_widget.dart';
import 'package:front_gestion_minera/modules/surveillance/presentation/widget/success_receipt_dialog_widget.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

class RegisyerContributionsView extends StatefulWidget {
  const RegisyerContributionsView({super.key});

  @override
  State<RegisyerContributionsView> createState() => _RegisyerContributionsViewState();
}

class _RegisyerContributionsViewState extends State<RegisyerContributionsView> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onCalculatePressed() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      CustomAlert.show(
        context,
        title: 'Monto Inválido',
        message: 'Por favor, ingrese un monto válido.',
        type: AlertType.error,
      );
      return;
    }

    FocusScope.of(context).unfocus();
    _showCalculationPreview();
  }

  void _showCalculationPreview() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CalculationPreviewSheet(
        montoTotal: double.tryParse(_amountController.text) ?? 5000.0,
        cantidadPersonas: 2,
        montoPorPersona: 2500.0, 
        onConfirm: () {
          Navigator.pop(context); 
          _showSuccessReceipt(); 
          _amountController.clear();
        },
      ),
    );
  }

  void _showSuccessReceipt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SuccessReceiptDialog(
        montoTotal: 5000.0,
        cantidadPersonas: 2,
        montoPorPersona: 2500.0,
        fecha: "09/03/2026",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final smallSpacing = screenSize.height * 0.02;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Registro de Aporte",
            style: AppTextStyles.mainStyle16Bold(
              context,
            ).copyWith(fontSize: 20),
          ),
          SizedBox(height: smallSpacing * 0.5),
          Text(
            "Ingrese el monto que será procesado para el cálculo de aportes por persona.",
            style: AppTextStyles.mainStyle12(
              context,
            ).copyWith(color: colors.lead),
          ),
          SizedBox(height: smallSpacing * 1.5),
          Text(
            "Monto Total (Bs.)",
            style: AppTextStyles.mainStyle12Bold(
              context,
            ).copyWith(color: colors.black.withValues(alpha:  0.8)),
          ),
          const SizedBox(height: 8),
          AmountInputField(controller: _amountController, colors: colors),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _onCalculatePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Calcular',
                style: AppTextStyles.mainStyle14Bold(
                  context,
                ).copyWith(color: colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

