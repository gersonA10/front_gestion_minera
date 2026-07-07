import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:intl/intl.dart';

import '../../../domain/entity/entity.dart';

class TransactionTile extends StatelessWidget {
  final PaymentHistoryItemEntity item;

  const TransactionTile({super.key, required this.item});

  static const _textPrimary = Color(0xFF0D1B3E);
  static const _textSecondary = Color(0xFF6B7A99);
  static const _border = Color(0xFFE8EDF5);
  static const _green = Color(0xFF17A05D);
  static const _red = Color(0xFFD32F2F);
  static const _primary = Color(0xFF1A56FF);

  @override
  Widget build(BuildContext context) {
    final isIncome = item.operationType.toUpperCase() == 'INCOME';
    final color = isIncome ? _green : _red;
    final money = NumberFormat('#,##0.00', 'en_US').format(item.monto);
    final amountStr = '${isIncome ? '+' : '-'}Bs $money';
    final title = item.description?.isNotEmpty == true
        ? item.description!
        : (isIncome ? 'Ingreso' : 'Egreso');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1B3E).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.router.push(
            TransactionDetailsRoute(idTransaction: item.transactionId),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    isIncome
                        ? Icons.south_west_rounded
                        : Icons.north_east_rounded,
                    size: 22,
                    color: color,
                  ),
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
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 12, color: _textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('HH:mm').format(item.fecha.toLocal()),
                            style: const TextStyle(
                                fontSize: 11.5, color: _textSecondary),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: Color(0xFFC9D2E0),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              item.destinoDinero,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11.5, color: _textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amountStr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isIncome ? _green : _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ver detalle',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: _primary,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 10, color: _primary),
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
