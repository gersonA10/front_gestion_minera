import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants/color.constant.dart';
import '../../domain/entity/entity.dart';

class CardRequestDetailWidget extends StatelessWidget {
  final TransactionHistoryEntity transaction;

  const CardRequestDetailWidget({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(transaction.statusKey);
    final formattedAmount = NumberFormat('#,##0.00', 'es_BO').format(transaction.amount);
    final date = DateFormat('dd/MM/yyyy').format(transaction.transactionDate);
    final time = DateFormat('hh:mm a').format(transaction.transactionDate);

    return Container(
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
                child: Icon(
                  transaction.operationType == 'EXPENSE'
                      ? Icons.shopping_cart_outlined
                      : Icons.arrow_downward_rounded,
                  color: color,
                ),
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
                    Row(
                      children: [
                        Text(
                          date,
                          style: TextStyle(color: TColors.textFieldDisabledColor, fontSize: 12),
                        ),
                        const SizedBox(width: 5),
                        Icon(Icons.circle, size: 5, color: TColors.textFieldDisabledColor),
                        const SizedBox(width: 5),
                        Text(
                          time,
                          style: TextStyle(color: TColors.textFieldDisabledColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(statusKey: transaction.statusKey, label: transaction.statusLabel),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monto Total',
                    style: TextStyle(fontSize: 12, color: TColors.appDisabledColor),
                  ),
                  Text(
                    '$formattedAmount Bs',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    );
  }

  Color _colorFor(String statusKey) {
    switch (statusKey) {
      case 'IN_REVIEW':
        return TColors.appMainColor;
      case 'PAID':
      case 'COMPLETED':
        return TColors.green;
      case 'PENDING_RECEIPT':
        return TColors.amber;
      default:
        return TColors.red;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String statusKey;
  final String label;

  const _StatusBadge({required this.statusKey, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(statusKey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(maxWidth: 120),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _colorFor(String statusKey) {
    switch (statusKey) {
      case 'IN_REVIEW':
        return TColors.appMainColor;
      case 'PAID':
      case 'COMPLETED':
        return TColors.green;
      case 'PENDING_RECEIPT':
        return TColors.amber;
      default:
        return TColors.red;
    }
  }
}
