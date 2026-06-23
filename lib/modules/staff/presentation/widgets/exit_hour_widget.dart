import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';

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
        const StaffSectionTitle(
          'Hora de salida',
          icon: Icons.logout_rounded,
        ),

        const SizedBox(height: 12),

        StaffCard(
          padding: EdgeInsets.zero,
          onTap: onSelectTime,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    color: StaffUi.primary),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    formatearHora(endTime),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: StaffUi.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                const Icon(Icons.edit_rounded,
                    color: StaffUi.textSecondary, size: 20),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Se utilizará la hora actual del dispositivo por defecto.',
          style: TextStyle(fontSize: 12, color: StaffUi.textSecondary),
        ),
      ],
    );
  }
}