import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class CurrentShiftCard extends StatelessWidget {
  final String? workerPhoto;
  final TimeOfDay startTime;
  final String Function(TimeOfDay) formatearHora;

  const CurrentShiftCard({
    super.key,
    this.workerPhoto,
    required this.startTime,
    required this.formatearHora,
  });

  @override
  Widget build(BuildContext context) {
    return StaffCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: StaffUi.primarySoft,
            backgroundImage: workerPhoto != null && workerPhoto!.isNotEmpty
                ? NetworkImage(workerPhoto!)
                : null,
            child: workerPhoto == null || workerPhoto!.isEmpty
                ? const Icon(Icons.person_outline_rounded,
                    size: 30, color: StaffUi.primary)
                : null,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TURNO ACTUAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: StaffUi.textSecondary,
                    letterSpacing: 0.4,
                  ),
                ),

                const SizedBox(height: 8),

                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Entrada: ',
                        style: TextStyle(color: StaffUi.textSecondary),
                      ),

                      TextSpan(
                        text: formatearHora(startTime),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: StaffUi.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                const Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: TColors.statusGreen, size: 16),

                    SizedBox(width: 4),

                    Text(
                      'En planta - Sector Norte',
                      style: TextStyle(color: TColors.statusGreen, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}