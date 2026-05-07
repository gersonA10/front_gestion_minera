import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/camp/presentation/widgets/widgets.dart';

import '../../../../utils/constants/color.constant.dart';

class CardRequestDetailWidget extends StatelessWidget {
  final String state;
  const CardRequestDetailWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navegar a la pantalla de detalles de la solicitud
      },
      child: Container(
        width: .infinity,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: .start,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: TColors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.shopping_cart_outlined, color: TColors.green),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        'Compra de suministros - comedor',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'fecha',
                            style: TextStyle(
                              color: TColors.textFieldDisabledColor,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(
                            Icons.circle,
                            size: 6,
                            color: TColors.textFieldDisabledColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'hora: AM/PM',
                            style: TextStyle(
                              color: TColors.textFieldDisabledColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                StatusBadgeWidget(statusId: state),
              ],
            ),
            const SizedBox(height: 15),
            Column(
              crossAxisAlignment: .start,
              children: [
                const Text('Monto Total'),
                Row(
                  children: [
                    Text(
                      '4.500 Bs',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
