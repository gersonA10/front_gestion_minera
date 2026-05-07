import 'package:flutter/material.dart';

import '../../../../utils/constants/color.constant.dart';

class CardDashboardCampWidget extends StatelessWidget {
  final String type;
  const CardDashboardCampWidget({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: (type == 'activo')
            ? EdgeInsets.only(right: 8)
            : EdgeInsets.only(left: 8),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: (type == 'activo')
                    ? TColors.appMainColor.withValues(alpha: 0.2)
                    : TColors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: (type == 'activo')
                  ? Icon(Icons.content_paste, color: TColors.appMainColor)
                  : Icon(Icons.check_circle_rounded, color: TColors.green),
            ),
            const SizedBox(height: 10),
            Text((type == 'activo') ? 'Solicitudes Activas' : 'Completadas'),
            Text(
              (type == 'activo') ? '12' : '84',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
