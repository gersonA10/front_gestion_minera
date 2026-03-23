
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

class CustomCardMetric extends StatelessWidget {
  const CustomCardMetric({
    required this.title,
    required this.amount,
    required this.bgColor,
    required this.titleColor,
    required this.amountColor,
    super.key,
  });

  final String title;
  final String amount;
  final Color bgColor;
  final Color titleColor;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isWhite = bgColor == colors.white;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 8.0, bottom: 4.0, top: 4.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: isWhite ? Border.all(color: colors.bajo, width: 1.5) : null,
        boxShadow: isWhite
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))]
            : [BoxShadow(color: bgColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.mainStyle10Bold(context).copyWith(color: titleColor),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: AppTextStyles.mainStyle20Bold(context).copyWith(color: amountColor),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
