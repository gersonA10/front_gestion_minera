import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants/color.constant.dart';
import '../../domain/entity/entity.dart';

class CardRequestDetailWidget extends StatelessWidget {
  final TransactionHistoryEntity transaction;

  const CardRequestDetailWidget({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(transaction.globalStatus);
    final amount = transaction.finalAmount ?? transaction.requestedAmount;
    final formattedAmount = NumberFormat('#,##0.00', 'es_BO').format(amount);
    final date = DateFormat('dd/MM/yyyy').format(transaction.createdAt);

    return GestureDetector(
      onTap: () {
        context.router.push(
          RequestProgressDetailsRoute(requestId: transaction.requestId),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.receipt_long_outlined, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        date,
                        style: TextStyle(
                          color: TColors.textFieldDisabledColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(
                  globalStatus: transaction.globalStatus,
                  label: transaction.statusLabel,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monto Solicitado',
                      style: TextStyle(
                        fontSize: 12,
                        color: TColors.appDisabledColor,
                      ),
                    ),
                    Text(
                      '$formattedAmount Bs',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  transaction.requestCode,
                  style: TextStyle(fontSize: 12, color: TColors.appDisabledColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Color _statusColor(String globalStatus) {
  switch (globalStatus) {
    case 'IN_REVIEW':
      return TColors.appMainColor;
    case 'APPROVED':
      return TColors.amber;
    case 'PAID':
      return TColors.green;
    case 'REJECTED':
      return TColors.danger;
    default:
      return TColors.appDisabledColor;
  }
}

class _StatusBadge extends StatelessWidget {
  final String globalStatus;
  final String label;

  const _StatusBadge({required this.globalStatus, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(globalStatus);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(maxWidth: 130),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
