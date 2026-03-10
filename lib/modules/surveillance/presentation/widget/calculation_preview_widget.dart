import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/modules/surveillance/presentation/widget/success_receipt_dialog_widget.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

class CalculationPreviewSheet extends StatelessWidget {
  final double montoTotal;
  final int cantidadPersonas;
  final double montoPorPersona;
  final VoidCallback onConfirm;

  const CalculationPreviewSheet({super.key, 
    required this.montoTotal,
    required this.cantidadPersonas,
    required this.montoPorPersona,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate_outlined, color: colors.blue, size: 28),
                const SizedBox(width: 8),
                Text(
                  "Previsualización",
                  style: AppTextStyles.mainStyle16Bold(
                    context,
                  ).copyWith(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 24),
            DetailRow(
              label: "Monto Total:",
              value: "Bs. $montoTotal",
              isBold: true,
            ),
            const Divider(height: 24),
            DetailRow(label: "Cantidad Personas:", value: "$cantidadPersonas"),
            const Divider(height: 24),
            DetailRow(
              label: "Monto por Persona:",
              value: "Bs. $montoPorPersona",
              isBold: true,
              valueColor: colors.green,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: colors.lead.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: AppTextStyles.mainStyle14Bold(
                        context,
                      ).copyWith(color: colors.lead),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Registrar',
                      style: AppTextStyles.mainStyle14Bold(
                        context,
                      ).copyWith(color: colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


