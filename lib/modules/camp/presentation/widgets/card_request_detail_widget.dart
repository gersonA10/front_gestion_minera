import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants/color.constant.dart';
import '../../domain/entity/entity.dart';

class _C {
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0D1B3E);
  static const textSecondary = Color(0xFF6B7A99);
  static const textMuted = Color(0xFF94A3B8);
  static const border = Color(0xFFE8EDF5);
}

class CardRequestDetailWidget extends StatelessWidget {
  final TransactionHistoryEntity transaction;
  final VoidCallback? onReturn;

  const CardRequestDetailWidget({
    super.key,
    required this.transaction,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    // Si tiene reposición pendiente, NO está realmente completada: se muestra
    // ese estado en ámbar por encima del estado base.
    final isReposicion = transaction.reconciliationStatus == 'PENDING';
    final status = isReposicion
        ? const _StatusStyle(TColors.amber, Icons.sync_problem_rounded)
        : _statusStyleFor(transaction.globalStatus);
    final statusLabel =
        isReposicion ? 'Reposición pendiente' : transaction.statusLabel;
    final hasFinal = transaction.finalAmount != null;
    final amount = transaction.finalAmount ?? transaction.requestedAmount;
    final fmt = NumberFormat('#,##0.00', 'es_BO');
    final date = DateFormat('dd/MM/yyyy').format(transaction.createdAt);
    final title = transaction.description.split(' - ').first;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await context.router.push(
              RequestProgressDetailsRoute(requestId: transaction.requestId),
            );
            onReturn?.call();
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
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
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: _C.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 11,
                                color: _C.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                date,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11.5,
                                  color: _C.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(color: status.color, label: statusLabel),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: _C.border),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasFinal ? 'Monto final' : 'Monto solicitado',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: _C.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${fmt.format(amount)} Bs',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _C.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          transaction.requestCode,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: _C.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: _C.textSecondary,
                        ),
                      ],
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
                fontFamily: 'Poppins',
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
    case 'COMPLETED':
      return const _StatusStyle(TColors.green, Icons.verified_rounded);
    case 'REJECTED':
      return const _StatusStyle(TColors.danger, Icons.cancel_rounded);
    default:
      return const _StatusStyle(TColors.appMainColor, Icons.receipt_long_rounded);
  }
}
