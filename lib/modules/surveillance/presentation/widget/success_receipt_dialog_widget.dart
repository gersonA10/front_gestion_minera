import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

class SuccessReceiptDialog extends StatelessWidget {
  final double montoTotal;
  final int cantidadPersonas;
  final double montoPorPersona;
  final String fecha;

  const SuccessReceiptDialog({
    super.key,
    required this.montoTotal,
    required this.cantidadPersonas,
    required this.montoPorPersona,
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: colors.green, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              "¡Registro Exitoso!",
              style: AppTextStyles.mainStyle16Bold(
                context,
              ).copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              "El aporte ha sido registrado correctamente.",
              textAlign: TextAlign.center,
              style: AppTextStyles.mainStyle12(
                context,
              ).copyWith(color: colors.lead),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.lead.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  DetailRow(label: "Fecha:", value: fecha),
                  const SizedBox(height: 8),
                  DetailRow(label: "Monto Total:", value: "Bs. $montoTotal"),
                  const SizedBox(height: 8),
                  DetailRow(label: "Personas:", value: "$cantidadPersonas"),
                  const SizedBox(height: 8),
                  DetailRow(
                    label: "Por persona:",
                    value: "Bs. $montoPorPersona",
                    isBold: true,
                    valueColor: colors.green,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(
                  //     content: Text('Descargando comprobante PDF...'),
                  //   ),
                  // );
                  CustomAlert.show(
                    context,
                    title: 'Descargando...',
                    message:
                        'Por favor, espere mientras se descarga el comprobante.',
                    type: AlertType.warning,
                  );
                },
                icon: Icon(Icons.picture_as_pdf, color: colors.white, size: 20),
                label: Text(
                  'Descargar Comprobante',
                  style: AppTextStyles.mainStyle14Bold(
                    context,
                  ).copyWith(color: colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cerrar',
                  style: AppTextStyles.mainStyle14Bold(
                    context,
                  ).copyWith(color: colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.mainStyle14(
            context,
          ).copyWith(color: colors.lead),
        ),
        Text(
          value,
          style: AppTextStyles.mainStyle14(context).copyWith(
            color: valueColor ?? colors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
