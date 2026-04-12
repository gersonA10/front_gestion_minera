
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

import '../../../domain/entity/entity.dart';

class DividendCard extends StatelessWidget {
  const DividendCard({required this.item, super.key});
  final DistributesHistoryEntity item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isPaid = item.status.toLowerCase() == 'pagado';
    final statusColor = isPaid ? colors.green : colors.amber;
    final iconData = isPaid ? Icons.payments_outlined : Icons.pending_actions_outlined;

    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final dateInfo = '${item.registeredDate.day.toString().padLeft(2, '0')} ${months[item.registeredDate.month - 1]} ${item.registeredDate.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(iconData, color: statusColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: AppTextStyles.mainStyle12Bold(context).copyWith(color: colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateInfo,
                  style: AppTextStyles.mainStyle10(context).copyWith(color: colors.lead),
                )
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Bs ${item.amount.toStringAsFixed(2)}',
                style: AppTextStyles.mainStyle12Bold(context).copyWith(color: colors.black),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.status.toUpperCase(),
                  style: AppTextStyles.mainStyle10Bold(context).copyWith(color: statusColor, fontSize: 9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}