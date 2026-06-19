import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:intl/intl.dart';
import '../../../domain/entity/entity.dart';
import '../../screens/contributes/contributes_ui.dart';

class AporteCard extends StatelessWidget {
  final ContributeItemEntity item;

  const AporteCard({super.key, required this.item});

  /// (texto, color, fondo, ícono) del estado según el avance.
  (String, Color, Color, IconData) _status() {
    if (item.progressPercentage >= 100) {
      return ('Completado', CUi.success, CUi.successBg,
          Icons.check_circle_rounded);
    }
    if (item.progressPercentage <= 0) {
      return ('Por recaudar', CUi.warning, CUi.warningBg,
          Icons.hourglass_top_rounded);
    }
    return ('En curso', CUi.primary, CUi.primarySoft, Icons.autorenew_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'es_PE');
    final progress = item.progressPercentage / 100.0;
    final collected = item.collectionGoal * progress;
    final pending = item.collectionGoal - collected;
    final fechaConvertida = DateTime.parse(item.creationDate);
    final (sLabel, sColor, sBg, sIcon) = _status();

    return CCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.reason,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: CUi.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CPill(label: sLabel, color: sColor, bg: sBg, icon: sIcon),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: CUi.textSecondary),
              const SizedBox(width: 4),
              Text(
                item.period.trim().isEmpty ? '—' : item.period.trim(),
                style: const TextStyle(fontSize: 13, color: CUi.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: CUi.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CStat(
                    label: 'Meta Total',
                    value: '${fmt.format(item.collectionGoal)} Bs',
                  ),
                ),
                Container(width: 1, height: 34, color: CUi.border),
                const SizedBox(width: 14),
                Expanded(
                  child: CStat(
                    label: 'Por Socio',
                    value: '${fmt.format(item.individualAmount)} Bs',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CProgress(
            value: progress,
            color: sColor == CUi.warning ? CUi.primary : sColor,
            leftLabel: 'Progreso de recaudación',
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${fmt.format(collected)} Bs recaudado',
                style: const TextStyle(fontSize: 12, color: CUi.textSecondary),
              ),
              Text(
                '${fmt.format(pending)} Bs pendiente',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: CUi.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          COutlinedButton(
            label: 'Ver detalle',
            icon: Icons.arrow_forward_rounded,
            onPressed: () {
              context.router.push(
                ContributesDetailRoute(
                  contributionId: item.contributionId,
                  dateContibution: fechaConvertida,
                  titleContibuton: item.reason,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
