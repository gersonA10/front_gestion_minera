import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class CardStateMachineryWidget extends StatelessWidget {
  final String state;
  const CardStateMachineryWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: (state == 'Activo')
            ? EdgeInsets.only(right: 10)
            : EdgeInsets.only(left: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  (state == 'Activo')
                      ? Icons.check_circle_outline_outlined
                      : Icons.warning_amber,
                  color: (state == 'Activo') ? TColors.green : TColors.red,
                ),
                Spacer(),
                Text(
                  (state == 'Activo') ? 'ACTIVO' : 'PARADO',
                  style: TextStyle(
                    color: (state == 'Activo') ? TColors.green : TColors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text((state == 'Activo') ? 'OPERATIVAS' : 'INACTIVAS'),
            Text(
              '98',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
