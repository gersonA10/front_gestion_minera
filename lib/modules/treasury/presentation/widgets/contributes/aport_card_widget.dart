
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import '../../../domain/entity/entity.dart';
import '../widgtes.dart';

class AporteCard extends StatelessWidget {
  final ContributeItemEntity item;

  const AporteCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final progress = item.progressPercentage / 100.0;
    final collected = item.collectionGoal * progress;
    final pending = item.collectionGoal - collected;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.border),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.reason,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: TColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: TColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                item.period.trim().isEmpty ? '—' : item.period.trim(),
                style: const TextStyle(
                  fontSize: 13,
                  color: TColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: TColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: MetaItemContibutes(
                    label: 'Meta Total',
                    value: '${item.collectionGoal.toStringAsFixed(0)} Bs',
                  ),
                ),
                Container(width: 1, height: 36, color: TColors.border),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: MetaItemContibutes(
                      label: 'Por Socio',
                      value: '${item.individualAmount.toStringAsFixed(2)} Bs',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso Recaudación',
                style: TextStyle(
                  fontSize: 13,
                  color: TColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${item.progressPercentage}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: TColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: TColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(TColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${collected.toStringAsFixed(0)} Bs Recaudado',
                style: const TextStyle(
                  fontSize: 12,
                  color: TColors.textSecondary,
                ),
              ),
              Text(
                '${pending.toStringAsFixed(0)} Bs Pendiente',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: TColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: TColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: TColors.textPrimary,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ver detalle',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: TColors.textPrimary,
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