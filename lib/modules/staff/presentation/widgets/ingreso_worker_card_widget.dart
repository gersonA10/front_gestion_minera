
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/staff/presentation/screens/attendance_ingreso_tab.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class IngresoWorkerCard extends StatelessWidget {
  final IngresoWorker worker;
  final VoidCallback onRegister;

  const IngresoWorkerCard({super.key, required this.worker, required this.onRegister});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: TColors.profileIconBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: TColors.avatarIconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worker.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: TColors.profileDarkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        worker.role,
                        style: const TextStyle(
                          fontSize: 12,
                          color: TColors.profileMutedLabel,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: worker.isLate
                                ? TColors.warning
                                : TColors.profileMutedLabel,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Programado: ${worker.scheduledTime}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: worker.isLate
                                  ? TColors.warning
                                  : TColors.profileMutedLabel,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: onRegister,
                icon: const Icon(Icons.login_rounded, size: 16),
                label: const Text(
                  'Registrar Entrada',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: TColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
