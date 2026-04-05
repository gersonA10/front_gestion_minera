import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class SummaryCardDistributes extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Color bgColor;
  final bool fullWidth;

  const SummaryCardDistributes({super.key, 
    required this.label,
    required this.value,
    required this.valueColor,
    required this.bgColor,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
