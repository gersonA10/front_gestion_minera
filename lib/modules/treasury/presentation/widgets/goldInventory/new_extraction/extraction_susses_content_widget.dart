import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class ExtractionSuccessContent extends StatelessWidget {
  final String loteId;
  final String pesoGramos;
  final bool isRecovered;
  final String message;

  const ExtractionSuccessContent({
    super.key,
    required this.loteId,
    required this.pesoGramos,
    required this.isRecovered,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: TColors.textPrimary.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: TColors.successLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: TColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: TColors.success, width: 3),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 28,
                  color: TColors.success,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isRecovered ? 'Extracción recuperada' : 'Extracción registrada',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: TColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: TColors.textSecondary,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: isRecovered
                      ? 'Este lote ya estaba registrado. Recuperamos '
                            'la operación original sin duplicarla: '
                      : 'Se registró correctamente el lote ',
                ),
                TextSpan(
                  text: '#$loteId',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                  ),
                ),
                const TextSpan(text: ' con '),
                TextSpan(
                  text: '$pesoGramos gramos',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                  ),
                ),
                const TextSpan(text: ' de oro.'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: TColors.goldAccentLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: TColors.goldAccent.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: TColors.goldAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    size: 22,
                    color: TColors.goldAccent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ID DE LOTE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: TColors.goldAccent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        loteId,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: TColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'PESO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: TColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$pesoGramos g',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: TColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                context.router.back();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  CustomAlert.show(
                    context,
                    title: 'Éxito',
                    message: message,
                    type: AlertType.success,
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Volver al Inventario',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
