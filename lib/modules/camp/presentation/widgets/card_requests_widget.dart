import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants/color.constant.dart';
import '../../domain/entity/entity.dart';

/// Paleta compartida con los módulos de socios y hacienda.
class _C {
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0D1B3E);
  static const textSecondary = Color(0xFF6B7A99);
  static const border = Color(0xFFE8EDF5);
}

class CardRequestsWidget extends StatelessWidget {
  final CampRecentRequestEntity request;

  const CardRequestsWidget({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    // Con reposición pendiente la solicitud no está completada: se prioriza
    // ese estado en ámbar.
    final isReposicion = request.reconciliationStatus == 'PENDING';
    final status = isReposicion
        ? const _StatusStyle(TColors.amber, Icons.sync_problem_rounded)
        : _statusStyleFor(request.globalStatus);
    final statusLabel =
        isReposicion ? 'Reposición pendiente' : request.statusLabel;
    final title = request.description.split(' - ').first;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.router.push(
            RequestProgressDetailsRoute(requestId: request.requestId),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Ícono que refleja el estado de la solicitud.
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(status.icon, color: status.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${request.displayCode}  ·  '
                        '${DateFormat('dd/MM/yyyy').format(request.createdAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: _C.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatusBadge(color: status.color, label: statusLabel),
                    const SizedBox(height: 6),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: _C.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Color color;
  final String label;

  const _StatusBadge({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      constraints: const BoxConstraints(maxWidth: 120),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStyle {
  final Color color;
  final IconData icon;
  const _StatusStyle(this.color, this.icon);
}

_StatusStyle _statusStyleFor(String globalStatus) {
  switch (globalStatus) {
    case 'IN_REVIEW':
      return const _StatusStyle(
        TColors.appMainColor,
        Icons.hourglass_top_rounded,
      );
    case 'APPROVED':
      return const _StatusStyle(TColors.amber, Icons.task_alt_rounded);
    case 'PAID':
      return const _StatusStyle(TColors.green, Icons.verified_rounded);
    case 'REJECTED':
      return const _StatusStyle(TColors.danger, Icons.cancel_rounded);
    default:
      return const _StatusStyle(TColors.danger, Icons.help_outline_rounded);
  }
}
