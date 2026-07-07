import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

class AmountInputField extends StatelessWidget {
  final TextEditingController controller;
  final ColorScheme colors;

  const AmountInputField({super.key, required this.controller, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.lead.withValues(alpha: 0.3)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: AppTextStyles.mainStyle16Bold(
          context,
        ).copyWith(color: colors.black),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.attach_money,
            color: colors.lead.withValues(alpha: 0.8),
          ),
          hintText: 'Ej. 5000',
          hintStyle: AppTextStyles.mainStyle14(
            context,
          ).copyWith(color: colors.lead.withValues(alpha: 0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

