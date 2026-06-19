import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/utils/text_util.dart';
import 'package:intl/intl.dart';

class MetricCardWidget extends StatelessWidget {
  const MetricCardWidget({
    super.key,
    required this.colors,
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
    this.percentage = 0.0,
    this.subtitle,
  });

  final ColorScheme colors;
  final String title;
  final double amount;
  final IconData icon;
  final Color iconColor;
  final double percentage;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.lead.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTextStyles.mainStyleGrey10(context).copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(icon, color: iconColor, size: 18),
              ],
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${formatCurrency.format(amount)} Bs',
                style: AppTextStyles.mainStyle20Bold(context).copyWith(
                  fontSize: 19,
                  color: colors.black,
                ),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.mainStyle10(context).copyWith(
                        color: colors.lead.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}