
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/staff/presentation/screens/attendance_finalizados_tab.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class FinalizadoWorkerCard extends StatelessWidget {
  final FinalizadoWorker worker;

  const FinalizadoWorkerCard({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    final isRevision = worker.status == FinalizadoStatus.revision;

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
                _buildAvatar(),
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
                        '${worker.shift} • ${worker.department}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: TColors.profileMutedLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(isRevision),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: TColors.border),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Entrada',
                        style: TextStyle(
                          fontSize: 11,
                          color: TColors.profileMutedLabel,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        worker.entryTime,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: TColors.profileDarkText,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: TColors.profileMutedLabel,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Salida',
                        style: TextStyle(
                          fontSize: 11,
                          color: TColors.profileMutedLabel,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        worker.exitTime,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: TColors.profileDarkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tiempo total trabajado',
                  style: TextStyle(
                    fontSize: 12,
                    color: TColors.profileMutedLabel,
                  ),
                ),
                Text(
                  worker.totalTime,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: worker.totalTimeColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: worker.avatarColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        worker.initials,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  // El registro está completado (tiene salida) → "Finalizado" siempre. Si la
  // jornada fue corta (< 8h netas), se agrega aparte una etiqueta informativa
  // neutra "Jornada corta" (es un dato, no una acción pendiente).
  Widget _buildStatusBadge(bool isShortShift) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _pill('Finalizado', TColors.success, TColors.successLight,
            Icons.check_circle_rounded),
        if (isShortShift) ...[
          const SizedBox(height: 4),
          _pill('Jornada corta', TColors.textSecondary, TColors.statusGreyBg,
              Icons.info_outline_rounded),
        ],
      ],
    );
  }

  Widget _pill(String label, Color color, Color bg, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 3),
          Icon(icon, size: 12, color: color),
        ],
      ),
    );
  }
}
