import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class TapField extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const TapField({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: TColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: TColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: TColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(icon, size: 18, color: TColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
