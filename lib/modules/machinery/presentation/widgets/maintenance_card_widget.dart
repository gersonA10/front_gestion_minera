import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/entity.dart';

class MaintenanceCard extends StatelessWidget {
  final MaintenanceHistoryItemEntity item;
  final VoidCallback? onTap;

  const MaintenanceCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = _GlobalStatus.from(item.globalStatus);
    final date = DateFormat('dd MMM yyyy', 'es').format(item.requestedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: status.bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(status.icon, color: status.color, size: 21),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatFailureType(item.failureType),
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: TColors.textPrimary,
                              height: 1.25,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.event_rounded,
                                  size: 12.5, color: TColors.textSecondary),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '$date  ·  ${item.machineUniqueCode}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: TColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusPill(status: status),
                  ],
                ),
                if (item.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: TColors.textSecondary,
                      height: 1.45,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 1, color: TColors.border),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      'Monto estimado',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: TColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _money(item.estimatedAmount),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: TColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right_rounded,
                        size: 16, color: TColors.iconMuted),
                  ],
                ),
              ],
            ),
          ),
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

/// Formatea un monto (double) en bolivianos con separadores de miles.
String _money(double value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final neg = parts[0].startsWith('-');
  final digits = neg ? parts[0].substring(1) : parts[0];
  final buf = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return '${neg ? '-' : ''}$buf.${parts[1]} Bs';
}

class _StatusPill extends StatelessWidget {
  final _GlobalStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: status.color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class MaintenanceGlobalStatus {
  static const String inReview = 'IN_REVIEW';
  static const String approved = 'APPROVED';
  static const String completed = 'COMPLETED';
  static const String rejected = 'REJECTED';
  static const String paid = 'PAID';
}

class _GlobalStatus {
  final String label;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _GlobalStatus({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  factory _GlobalStatus.from(String raw) {
    switch (raw) {
      case MaintenanceGlobalStatus.inReview:
        return const _GlobalStatus(
          label: 'En revisión',
          color: TColors.warning,
          bgColor: TColors.warningLight,
          icon: Icons.schedule_rounded,
        );
      case MaintenanceGlobalStatus.approved:
        return const _GlobalStatus(
          label: 'Aprobado',
          color: TColors.success,
          bgColor: TColors.successLight,
          icon: Icons.thumb_up_alt_rounded,
        );
      case MaintenanceGlobalStatus.completed:
        return const _GlobalStatus(
          label: 'Completado',
          color: TColors.appMainColor,
          bgColor: TColors.primaryLight,
          icon: Icons.check_circle_rounded,
        );
      case MaintenanceGlobalStatus.rejected:
        return const _GlobalStatus(
          label: 'Rechazado',
          color: TColors.danger,
          bgColor: TColors.dangerLight,
          icon: Icons.cancel_rounded,
        );
      case MaintenanceGlobalStatus.paid:
        return const _GlobalStatus(
          label: 'Pagado',
          color: TColors.appMainDarkColor,
          bgColor: TColors.primaryLight,
          icon: Icons.payments_rounded,
        );
      default:
        return _GlobalStatus(
          label: raw,
          color: TColors.textSecondary,
          bgColor: TColors.background,
          icon: Icons.help_outline_rounded,
        );
    }
  }
}
