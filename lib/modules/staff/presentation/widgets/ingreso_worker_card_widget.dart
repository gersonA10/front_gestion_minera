
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/staff/presentation/screens/attendance_ingreso_tab.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class IngresoWorkerCard extends StatelessWidget {
  final IngresoWorker worker;
  final VoidCallback onRegister;

  /// Minutos antes de la hora programada en que se habilita el registro.
  static const int enableMinutesBefore = 30;

  const IngresoWorkerCard({super.key, required this.worker, required this.onRegister});

  /// Hora programada de hoy según `worker.scheduledTime` ("HH:mm").
  /// Devuelve null si no se puede interpretar (en ese caso no se bloquea).
  DateTime? _scheduledToday() {
    final parts = worker.scheduledTime.trim().split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final mm = parts[1].length >= 2 ? parts[1].substring(0, 2) : parts[1];
    final m = int.tryParse(mm);
    if (h == null || m == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h, m);
  }

  @override
  Widget build(BuildContext context) {
    final scheduled = _scheduledToday();
    final enabledAt = scheduled?.subtract(
      const Duration(minutes: enableMinutesBefore),
    );
    // Habilitado desde 30 min antes en adelante (sin límite después).
    // Si no se puede interpretar la hora, no bloqueamos.
    final canRegister =
        enabledAt == null || !DateTime.now().isBefore(enabledAt);
    final enabledAtLabel = enabledAt == null
        ? ''
        : '${enabledAt.hour.toString().padLeft(2, '0')}:${enabledAt.minute.toString().padLeft(2, '0')}';

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
                onPressed: canRegister ? onRegister : null,
                icon: Icon(
                  canRegister ? Icons.login_rounded : Icons.lock_clock_rounded,
                  size: 16,
                ),
                label: Text(
                  canRegister
                      ? 'Registrar Entrada'
                      : 'Disponible desde $enabledAtLabel',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: TColors.white,
                  disabledBackgroundColor: TColors.border,
                  disabledForegroundColor: TColors.textSecondary,
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
