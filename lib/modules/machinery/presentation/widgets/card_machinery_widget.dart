import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class CardMachineryWidget extends StatelessWidget {
  final int index;
  const CardMachineryWidget({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: TColors.appMainColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: getEstado('Excavadora'),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Excavadora-camion',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'detalles',
                style: TextStyle(color: TColors.textFieldDisabledColor),
              ),
            ],
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: ((index % 2) == 0)
                  ? TColors.green.withValues(alpha: 0.2)
                  : TColors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              ((index % 2) == 0) ? 'ACTIVO' : 'INACTIVO',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ((index % 2) == 0)
                    ? TColors.green.withValues(alpha: 0.9)
                    : TColors.red.withValues(alpha: 0.9),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
    Widget getEstado(String tipo) {
    if (tipo == 'Excavadora') {
      return Icon(
        Icons.handyman,
        color: TColors.appMainColor.withValues(alpha: 0.9),
      );
    }
    if (tipo == 'Camión') {
      return Icon(
        Icons.local_shipping_outlined,
        color: TColors.appMainColor.withValues(alpha: 0.9),
      );
    }
    if (tipo == 'Perforadora') {
      return Icon(
        Icons.precision_manufacturing,
        color: TColors.appMainColor.withValues(alpha: 0.9),
      );
    }
    return Icon(
      Icons.handyman,
      color: TColors.appMainColor.withValues(alpha: 0.9),
    );
  }
}
