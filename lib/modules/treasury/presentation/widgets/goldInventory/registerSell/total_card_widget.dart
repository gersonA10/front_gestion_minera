import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class TotalCard extends StatelessWidget {
  final double total;
  const TotalCard({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: TColors.appMainColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.appMainColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          const Text(
            'Total Estimado (Bs)',
            style: TextStyle(
              fontSize: 13,
              color: TColors.appMainColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Bs ${_formatCurrency(total)}',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: TColors.appMainColor,
              letterSpacing: -1.0,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatCurrency(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$intPart.${parts[1]}';
  }
}