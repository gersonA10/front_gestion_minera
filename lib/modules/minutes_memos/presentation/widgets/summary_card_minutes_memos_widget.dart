import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class SummaryCardMinutesMemosWidget extends StatelessWidget {
  final String type; // 'minute' o 'memo'
  final String value;

  const SummaryCardMinutesMemosWidget({
    super.key,
    required this.type,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final String title = (type == 'minute') ? 'Actas' : 'Memorandos';
    final IconData icon =
        (type == 'minute') ? Icons.description_outlined : Icons.mail_outline;
    final Color iconColor =
        (type == 'minute') ? TColors.appMainColor : Colors.red;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: TColors.appDisabledColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(icon, color: iconColor, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: TColors.cardInnerBg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}