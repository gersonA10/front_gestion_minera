import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';

class PayrollSummaryCardWidget extends StatelessWidget {
  final IconData icon;
  final String title;

  /// Monto ya formateado (incluye símbolo y separadores).
  final String amount;
  final String? badge;
  final Color iconColor;
  final Color amountColor;

  const PayrollSummaryCardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.amount,
    this.badge,
    required this.iconColor,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: StaffUi.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: StaffUi.border),
        boxShadow: StaffUi.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 17, color: iconColor),
              ),
              const Spacer(),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: StaffUi.primarySoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: StaffUi.primary,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11.5,
              color: StaffUi.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: amountColor,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
