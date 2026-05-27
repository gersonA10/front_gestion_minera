import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class AttendanceStatCardWidget extends StatelessWidget {
  final String label;
  final String value;
  final String valueLabel;
  final Color valueLabelColor;
  final double valueFontSize;

  const AttendanceStatCardWidget({
    super.key,
    required this.label,
    required this.value,
    required this.valueLabel,
    required this.valueLabelColor,
    this.valueFontSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: TColors.profileMutedLabel,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: valueFontSize,
                  fontWeight: FontWeight.w800,
                  color: TColors.profileDarkText,
                  height: 1,
                ),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  valueLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: valueLabelColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
