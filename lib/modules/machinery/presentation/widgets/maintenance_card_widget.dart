
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/entity.dart';

class MaintenanceCard extends StatelessWidget {
  final MaintenanceHistoryItemEntity item;

  const MaintenanceCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final status = _GlobalStatus.from(item.globalStatus);
    final formattedDate = DateFormat('dd MMM yyyy').format(item.requestedAt);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: TColors.appMainColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.build_circle,
                    color: TColors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatFailureType(item.failureType),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$formattedDate • ${item.machineUniqueCode}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status.bgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: status.color,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monto estimado',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                ),
                Text(
                  item.estimatedAmount.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatFailureType(String raw) {
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (w) =>
              w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase(),
        )
        .join(' ');
  }

}

class MaintenanceGlobalStatus {
  static const String inReview = 'IN_REVIEW';
  static const String approved = 'APPROVED';
  static const String completed = 'COMPLETED';
  static const String rejected = 'REJECTED';
}

class _GlobalStatus {
  final String label;
  final Color color;
  final Color bgColor;

  const _GlobalStatus({
    required this.label,
    required this.color,
    required this.bgColor,
  });

  factory _GlobalStatus.from(String raw) {
    switch (raw) {
      case MaintenanceGlobalStatus.inReview:
        return const _GlobalStatus(
          label: 'EN REVISIÓN',
          color: Color(0xFFD97706),
          bgColor: Color(0xFFFEF3C7),
        );
      case MaintenanceGlobalStatus.approved:
        return const _GlobalStatus(
          label: 'APROBADO',
          color: Color(0xFF16A34A),
          bgColor: Color(0xFFDCFCE7),
        );
      case MaintenanceGlobalStatus.completed:
        return const _GlobalStatus(
          label: 'COMPLETADO',
          color: Color(0xFF2563EB),
          bgColor: Color(0xFFEFF6FF),
        );
      case MaintenanceGlobalStatus.rejected:
        return const _GlobalStatus(
          label: 'RECHAZADO',
          color: Color(0xFFDC2626),
          bgColor: Color(0xFFFEE2E2),
        );
      default:
        return _GlobalStatus(
          label: raw,
          color: const Color(0xFF6B7280),
          bgColor: const Color(0xFFF3F4F6),
        );
    }
  }
}
