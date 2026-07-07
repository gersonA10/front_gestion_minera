
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/staff/presentation/screens/attendance_en_planta_tab.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class PlantaWorkerCard extends StatelessWidget {
  final PlantaWorker worker;
  final VoidCallback onRegisterExit;

  const PlantaWorkerCard({super.key, 
    required this.worker,
    required this.onRegisterExit,
  });

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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              worker.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: TColors.profileDarkText,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: TColors.statusActiveBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'En Turno',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: TColors.success,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: TColors.statusActiveDot,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        worker.department,
                        style: const TextStyle(
                          fontSize: 12,
                          color: TColors.profileMutedLabel,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.login_rounded,
                            size: 13,
                            color: TColors.profileMutedLabel,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Entrada',
                            style: TextStyle(
                              fontSize: 11,
                              color: TColors.profileMutedLabel,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            worker.entryTime,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: TColors.profileDarkText,
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
                onPressed: onRegisterExit,
                icon: const Icon(Icons.logout_rounded, size: 16),
                label: const Text(
                  'Registrar Salida',
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
