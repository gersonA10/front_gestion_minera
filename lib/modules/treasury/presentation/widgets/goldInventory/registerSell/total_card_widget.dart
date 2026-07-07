import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';

class TotalCard extends StatelessWidget {
  final double total;
  const TotalCard({super.key, required this.total});

  String _formatCurrency(double value) => NumberFormat.currency(
        locale: 'es_BO',
        symbol: 'Bs',
        decimalDigits: 2,
      ).format(value);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: TColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          const Text(
            'TOTAL ESTIMADO',
            style: TextStyle(
              fontSize: 11,
              color: TColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(total),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: TColors.primary,
              letterSpacing: -1.0,
            ),
          ),
        ],
      ),
    );
  }
}
