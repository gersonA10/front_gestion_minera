
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/screens/payment%20history/payment_history_screen.dart';
import 'package:intl/intl.dart';

import '../../../domain/entity/entity.dart';

class TransactionTile extends StatelessWidget {
  final PaymentHistoryItemEntity item;

  const TransactionTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(item.fecha);
    final amountStr =
        '-${NumberFormat('#,##0.00', 'en_US').format(item.monto)} Bs';
    final iconData = iconForTransaction(item.operationType, item.destinoDinero);
    final iconColor =
        iconColorForTransaction(item.operationType, item.destinoDinero);
    final iconBg =
        iconBgForTransaction(item.operationType, item.destinoDinero);
    final title =
        item.description?.isNotEmpty == true ? item.description! : item.operationType;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          // Ícono
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, size: 22, color: iconColor),
          ),
          const SizedBox(width: 12),
          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 13, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 3),
                    Text(
                      timeStr,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1D5DB),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        item.destinoDinero,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF9CA3AF)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Monto
          Text(
            amountStr,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}