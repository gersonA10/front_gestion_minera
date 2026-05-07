import 'package:flutter/material.dart';

import '../../../../utils/constants/color.constant.dart';

class CardDashboardCampWidget extends StatelessWidget {
  final String type;
  final int count;

  const CardDashboardCampWidget({
    super.key,
    required this.type,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = type == 'activo';
    return Expanded(
      child: Container(
        margin: isActive ? const EdgeInsets.only(right: 8) : const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: isActive
                    ? TColors.appMainColor.withValues(alpha: 0.2)
                    : TColors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isActive
                  ? Icon(Icons.content_paste, color: TColors.appMainColor)
                  : Icon(Icons.check_circle_rounded, color: TColors.green),
            ),
            const SizedBox(height: 10),
            Text(isActive ? 'Solicitudes Activas' : 'Completadas'),
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
