import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class AppBarDashboardGoldWidget extends StatelessWidget {
  const AppBarDashboardGoldWidget({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TColors.surface,
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.router.back(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: TColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: TColors.goldAccentLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.diamond_outlined,
              size: 18,
              color: TColors.goldAccent,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Inventario de Oro',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: TColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
