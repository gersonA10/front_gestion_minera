import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class ExitHourWidget extends StatelessWidget {
  final TimeOfDay endTime;
  final Future<void> Function() onSelectTime;
  final String Function(TimeOfDay) formatearHora;

  const ExitHourWidget({
    super.key,
    required this.endTime,
    required this.onSelectTime,
    required this.formatearHora,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hora de Salida',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 10),

        GestureDetector(
          onTap: onSelectTime,
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: TColors.disabled),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    formatearHora(endTime),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const Icon(Icons.edit_outlined, color: TColors.disabled),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Se utilizará la hora actual del dispositivo por defecto.',
          style: TextStyle(fontSize: 12, color: TColors.disabled),
        ),
      ],
    );
  }
}